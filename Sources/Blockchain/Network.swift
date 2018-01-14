/// An abstraction of the world wide web
public final class Network {
  /// IPv4
  public typealias Address = String

  private var servers: [Address: Server] = [:]

  public init() {
  }

  func ping(to address: Address) -> Server? {
    return self.servers[address]
  }

  func run(_ server: Server, address: String) throws {
    guard self.servers[address] == nil else { throw Error.addressCollision }
    self.servers[address] = server
    print("Run server: \(server) on address \(address)")
  }
}

public extension Network {
  public enum Error: Swift.Error {
    case addressCollision
  }
}

public protocol Server {
  var address: String { get }
}
