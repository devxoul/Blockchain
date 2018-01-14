import Foundation

public struct Block: Model {
  public let height: Int
  public let header: Header
  public let transactions: [Transaction]

  static let genesis = Block(
    height: 0,
    header: Header(
      version: 1,
      prevHash: "0000000000000000000000000000000000000000000000000000000000000000",
      timestamp: 1515855600, // 2018-01-14T00:00:00+9000 (My birthday!)
      bits: 0xE600ffff, // target to average 10s
      nonce: 279
    ),
    transactions: [
      Transaction(
        header: Transaction.Header(
          version: 1,
          prevHash: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
        amount: 100,
        signature: "dEddYWeRoGK2LHkHBolAhqizrKmi+q0EzZ4KfwIHVX8c11nkDZxzOaxANIZXOZGftHQi+RaR7tKn/D6h8/fFyJq7Ou5m1HWxjtw9lza35YI9dwPW/AOby1qrMpQvo4jq9s1Mwvfg74oL6pVVTTWqrIPhtjnU/n0/Or+wD8biqkD/McBo2oGAJ0FBxQyoJBn5n622BnLZrAoZH6gaCuqdetEs2dbfik8n252E2kcTSt8o+EIUHBMz8OjjqA3UUXMf7f+nlL7aZAxkc8nEPZIDsQVtiZwGZhlnlvekG+ZImpCoLPvEehsG6wtZ4oC5/nRDnvFfgjUiXcqng1bul/AqhQ==",
        sender: Transaction.Sender(
          publicKey: "MIIBCgKCAQEA2elqN1xvPbNpjh0zoeT/H644L7KMKFpv4ANwnNudo6J4fIuTlv3hIe/OPK06g+WdGz/SYY8mWrxEJ0m8ttXv3voHAIZZug09p/yku76r6RxnGq/rDdEfYRK7cFQhl3O6rKVyhmtt25FvP1dfIUH+yxal/9enBr6E/+J2gOMYCZZ79kXabNKxSHFYUTVrFzkzBO97EzYufHJjfSdkjONMiH4gnzSjCH8kDGtO+FH21s9d1H6cer4AoutaE8r1QFco8HbnnDEnNYxf691+V74fNHUVsURxC57Oy611FjAo8gyjbZESK3s1gWH3lCj2OyIda84P00kUD2UaWtmHiKvKAwIDAQAB"
        ),
        recipient: Transaction.Recipient(
          address: "87bed5fe0773fd310a6f310b2a143f89e922303be3593911e35df030e0117393"
        )
      )
    ]
  )

  /// https://en.bitcoin.it/wiki/Block_hashing_algorithm
  public struct Header: Model {
    public let version: UInt32
    public let prevHash: String
    public let timestamp: UInt32
    public let bits: BigInt
    public let nonce: UInt32

    public let hash: String
    public let isNonceValid: Bool

    init(
      version: UInt32,
      prevHash: String,
      timestamp: UInt32,
      bits: BigInt,
      nonce: UInt32
    ) {
      self.version = version
      self.prevHash = prevHash
      self.timestamp = timestamp
      self.bits = bits
      self.nonce = nonce

      let hash = Blockchain.hash(version, prevHash, timestamp, bits, nonce)
      self.hash = hash
      self.isNonceValid = {
        let targetHex = bits.hexString
        let targetPrefix = BigInt(String(targetHex.prefix(2)), radix: 16)!
        let targetRemain = BigInt(String(targetHex.suffix(targetHex.count - 2)), radix: 16)!
        let targetValue = targetRemain * pow(2, targetPrefix)
        let hashValue = BigInt(hash, radix: 16)!
        return hashValue <= targetValue
      }()
    }

    public func with(
      prevHash: String? = nil,
      timestamp: UInt32? = nil,
      bits: BigInt? = nil,
      nonce: UInt32? = nil
    ) -> Header {
      return Header(
        version: self.version,
        prevHash: prevHash ?? self.prevHash,
        timestamp: timestamp ?? self.timestamp,
        bits: bits ?? self.bits,
        nonce: nonce ?? self.nonce
      )
    }
  }
}

extension Block: CustomDebugStringConvertible {
  public var debugDescription: String {
    return "<Block height=\(self.height) bits=\(self.header.bits.hexString) nonce=\(self.header.nonce) transactions=\(self.transactions.count)>"
  }
}
