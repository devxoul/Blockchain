import Foundation
import CryptoSwift

protocol HashInputConvertible {
  var hashInput: String { get }
}

extension UInt32: HashInputConvertible {
  var hashInput: String {
    return String(self, radix: 16)
  }
}

extension UInt64: HashInputConvertible {
  var hashInput: String {
    return String(self, radix: 16)
  }
}

extension Double: HashInputConvertible {
  var hashInput: String {
    return String(Int(self * 100_000_000), radix: 16)
  }
}

extension _BigInt: HashInputConvertible {
  var hashInput: String {
    return self.hexString
  }
}

extension String: HashInputConvertible {
  var hashInput: String {
    return self
  }
}

@inline(__always)
func hash(_ values: HashInputConvertible...) -> String {
  return hash(values)
}

@inline(__always)
func hash(_ values: [HashInputConvertible]) -> String {
  return values.map { $0.hashInput }.joined().sha256().sha256()
}
