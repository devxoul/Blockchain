import Foundation
import RxSwift

public class Node: Server, RPCServer {
  private let network: Network
  private let scheduler: SchedulerType
  private let disposeBag = DisposeBag()
  private var proofingDisposable: Disposable?

  /// IPv4
  public let address: String
  fileprivate var neighbors: [Node] = []

  fileprivate var blocks: [Block] = [.genesis]
  fileprivate var unconfirmedTransactions: [Transaction] = []

  private var isProofing: Bool = false

  init(network: Network, scheduler: SchedulerType, address: String) throws {
    self.network = network
    self.scheduler = scheduler
    self.address = address
    try self.runServer()
    self.startFindingNodes()
    self.startProofing()
  }

  private func runServer() throws {
    try self.network.run(self, address: address)
  }


  // MARK: Node

  private func startFindingNodes() {
    Observable<Int>.interval(1, scheduler: self.scheduler)
      .subscribe(onNext: { [weak self] _ in
        guard let `self` = self else { return }
        for a in (0...10) {
          for b in (0...10) {
            for c in (0...10) {
              for d in (0...10) {
                let address = "\(a).\(b).\(c).\(d)"
                self.tryConnect(to: address)
              }
            }
          }
        }
      })
      .disposed(by: self.disposeBag)
  }

  private func tryConnect(to address: String) {
    guard address != self.address else { return }
    guard let node = self.network.ping(to: address) as? Node else { return }
    guard !self.neighbors.contains(where: { $0.address == address }) else { return }
    self.log("Connect node \(address)")
    self.neighbors.append(node)
    if node.blocks.count > self.blocks.count {
      self.log("Sync blocks from \(address)")
      self.blocks = node.blocks
    }
    if node.unconfirmedTransactions.count > self.unconfirmedTransactions.count {
      self.log("Sync transactions from \(address)")
      self.unconfirmedTransactions = node.unconfirmedTransactions
    }
  }


  // MARK: Send

  public func send(amount: Double, from sender: KeyPair, to receiver: String) throws {
    guard let lastTransaction = self.lastTransaction() else { return }
    let transaction = Transaction(
      header: Transaction.Header(
        version: 1,
        prevHash: lastTransaction.hash
      ),
      amount: amount,
      signature: try KeyPair.signature(Blockchain.hash(amount), privateKey: sender.privateKey.stringValue),
      sender: Transaction.Sender(publicKey: sender.publicKey.stringValue),
      recipient: Transaction.Recipient(address: receiver)
    )
    try self.rpc.createTransaction(transaction)
  }

  fileprivate func lastTransaction() -> Transaction? {
    return self.blocks.last?.transactions.last ?? self.unconfirmedTransactions.last
  }

  fileprivate func isValidTransaction(_ transaction: Transaction) -> Bool {
    guard let lastTransaction = self.lastTransaction() else { return false }
    guard transaction.header.prevHash == lastTransaction.hash else { return false }
    guard (try? KeyPair.verify(
      Blockchain.hash(transaction.amount),
      signature: transaction.signature,
      publicKey: transaction.sender.publicKey
    )) == true else { return false }
    return true
  }


  // MARK: Proof of Work

  fileprivate func startProofing() {
    self.proofingDisposable?.dispose()
    guard let lastBlock = self.blocks.last else { return }
    let timestamp = UInt32(Date().timeIntervalSince1970)

    enum ProofError: Swift.Error {
      case lastBlockChanged
    }

    self.proofingDisposable = Observable<UInt32>.from(0...UInt32.max)
      .flatMap { [weak self] nonce -> Observable<Block> in
        guard let `self` = self else { return .empty() }
        guard lastBlock.header.hash == self.blocks.last?.header.hash else {
          self.proofingDisposable?.dispose()
          return .error(ProofError.lastBlockChanged)
        }
        let header = lastBlock.header.with(
          prevHash: lastBlock.header.hash,
          timestamp: timestamp,
          nonce: nonce
        )
        guard self.isValidBlockHeader(header) else { return .empty() }
        let newBlock = Block(
          height: self.blocks.count,
          header: header,
          transactions: self.unconfirmedTransactions
        )
        return .just(newBlock)
      }
      .take(1)
      .subscribeOn(self.scheduler)
      .subscribe(onNext: { [weak self] block in try? self?.rpc.submitBlock(block) })
  }

  fileprivate func isValidBlockHeader(_ header: Block.Header) -> Bool {
    guard header.isNonceValid else { return false }
    guard header.prevHash == self.blocks.last?.header.hash else { return false }
    return true
  }

  fileprivate func isValidBlock(_ block: Block) -> Bool {
    guard self.isValidBlockHeader(block.header) else { return false }
    for transaction in block.transactions {
      guard self.isValidTransaction(transaction) else { return false }
    }
    return true
  }


  // MARK: Logging

  @inline(__always)
  fileprivate func log(_ values: Any?...) {
    let message = values.map { $0.map { String(describing: $0) } ?? "nil" }.joined()
    print("[Node@\(self.address)]", message)
  }
}


// MARK: - RPC

extension RPC where Server: Node {
  enum Error: Swift.Error {
    case invalid
    case duplicated
  }

  func submitBlock(_ block: Block) throws {
    guard self.server.isValidBlock(block) else { throw Error.invalid }
    guard !self.server.blocks.contains(block) else { throw Error.duplicated }
    self.server.log("Submit block: \(block)")
    self.server.blocks.append(block)
    self.server.unconfirmedTransactions.removeAll()
    for node in self.server.neighbors {
      try? node.rpc.submitBlock(block)
    }
    self.server.startProofing()
  }

  func createTransaction(_ transaction: Transaction) throws {
    guard self.server.isValidTransaction(transaction) else { throw Error.invalid }
    guard !self.server.unconfirmedTransactions.contains(transaction) else { throw Error.duplicated }
    self.server.log("Create transaction: \(transaction)")
    self.server.unconfirmedTransactions.append(transaction)
    for node in self.server.neighbors {
      try? node.rpc.createTransaction(transaction)
    }
  }
}
