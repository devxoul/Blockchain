public struct Transaction: Model {
  public let header: Header
  public let amount: Double
  public let sender: Sender
  public let recipient: Recipient
  public let signature: String
  public let hash: String

  init(
    header: Header,
    amount: Double,
    signature: String,
    sender: Sender,
    recipient: Recipient
  ) {
    self.header = header
    self.amount = amount
    self.signature = signature
    self.sender = sender
    self.recipient = recipient
    self.hash = Blockchain.hash(header.hash, amount, sender.hash, recipient.hash)
  }

  public struct Header: Model {
    public let version: UInt32
    public let prevHash: String
    public let hash: String

    init(version: UInt32, prevHash: String) {
      self.version = version
      self.prevHash = prevHash
      self.hash = Blockchain.hash(version, prevHash)
    }
  }

  public struct Sender: Model {
    public let publicKey: String
    public let hash: String

    init(publicKey: String) {
      self.publicKey = publicKey
      self.hash = Blockchain.hash(publicKey)
    }
  }

  public struct Recipient: Model {
    public let address: String
    public let hash: String

    init(address: String) {
      self.address = address
      self.hash = Blockchain.hash(address)
    }
  }
}

extension Transaction: CustomStringConvertible {
  public var description: String {
    return "<Transaction (\(self.amount)) \(self.sender.hash.prefix(16)) -> \(self.recipient.hash.prefix(16))>"
  }
}
