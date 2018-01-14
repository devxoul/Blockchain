import Foundation

/// https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/generating_new_cryptographic_keys
public struct KeyPair {
  enum KeyType {
    case rsa(Int)
  }

  enum KeyClass {
    case `public`
    case `private`
  }

  enum Error: Swift.Error {
    case unsupported
  }

  let privateKey: SecKey
  let publicKey: SecKey

  init() throws {
    guard #available(macOS 10.12, *) else { throw Error.unsupported }
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(KeyPair.attributes(class: .private), &error) else {
      throw error!.takeRetainedValue() as Swift.Error
    }
    self.privateKey = privateKey
    self.publicKey = SecKeyCopyPublicKey(privateKey)!
  }

  init(privateKey: String, publicKey: String) throws {
    guard #available(macOS 10.12, *) else { throw Error.unsupported }
    self.privateKey = try KeyPair.key(.private, from: privateKey)
    self.publicKey = try KeyPair.key(.public, from: publicKey)
  }

  private static func attributes(type: KeyType = .rsa(2048), class: KeyClass) -> CFDictionary {
    var dict: [CFString: Any] = [
      kSecPrivateKeyAttrs: [
        kSecAttrIsPermanent: true
      ]
    ]
    switch type {
    case let .rsa(size):
      dict[kSecAttrKeyType] = kSecAttrKeyTypeRSA
      dict[kSecAttrKeySizeInBits] = size
    }
    switch `class` {
    case .public: dict[kSecAttrKeyClass] = kSecAttrKeyClassPublic
    case .private: dict[kSecAttrKeyClass] = kSecAttrKeyClassPrivate
    }
    return dict as CFDictionary
  }

  private static func key(_ class: KeyClass, from string: String) throws -> SecKey {
    guard #available(macOS 10.12, *) else { throw Error.unsupported }
    var error: Unmanaged<CFError>?
    let data = Data(base64Encoded: string)! as CFData
    guard let key = SecKeyCreateWithData(data, KeyPair.attributes(class: `class`), &error) else {
      throw error!.takeRetainedValue() as Swift.Error
    }
    return key
  }

  /// https://developer.apple.com/library/content/documentation/Security/Conceptual/SecTransformPG/SigningandVerifying/SigningandVerifying.html
  static func signature(_ input: String, privateKey: String) throws -> String {
    let key = try self.key(.private, from: privateKey)
    let data = input.data(using: .utf8)! as CFData

    var error: Unmanaged<CFError>?
    guard let signer = SecSignTransformCreate(key, &error) else {
      throw error!.takeRetainedValue() as Swift.Error
    }
    SecTransformSetAttribute(signer, kSecTransformInputAttributeName, data, &error)
    if let error = error {
      throw error.takeRetainedValue() as Swift.Error
    }
    let signature = SecTransformExecute(signer, &error)
    if let error = error {
      throw error.takeRetainedValue() as Swift.Error
    }
    return (signature as! Data).base64EncodedString()
  }

  /// https://developer.apple.com/library/content/documentation/Security/Conceptual/SecTransformPG/SigningandVerifying/SigningandVerifying.html
  static func verify(_ input: String, signature: String, publicKey: String) throws -> Bool {
    let key = try self.key(.public, from: publicKey)
    let signature = Data(base64Encoded: signature)!
    var error: Unmanaged<CFError>?
    guard let verifier = SecVerifyTransformCreate(key, signature as CFData, &error) else {
      throw error!.takeRetainedValue() as Swift.Error
    }
    SecTransformSetAttribute(verifier, kSecTransformInputAttributeName, input.data(using: .utf8)! as CFData, &error)
    if let error = error {
      throw error.takeRetainedValue() as Swift.Error
    }
    guard let result = SecTransformExecute(verifier, &error) as? Bool else {
      throw error!.takeRetainedValue() as Swift.Error
    }
    return result
  }
}

extension SecKey {
  var stringValue: String {
    guard #available(macOS 10.12, *) else { return "" }
    guard let data = SecKeyCopyExternalRepresentation(self, nil) as Data? else { return "" }
    return data.base64EncodedString()
  }
}

