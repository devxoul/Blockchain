public protocol RPCServer {}
public extension RPCServer {
  var rpc: RPC<Self> {
    return RPC(server: self)
  }
}

public final class RPC<Server: RPCServer> {
  public let server: Server

  public init(server: Server) {
    self.server = server
  }
}
