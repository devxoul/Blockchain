import Foundation

public protocol Model: Codable, Equatable {
}

public extension Model {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return (try? JSONEncoder().encode(lhs)) == (try? JSONEncoder().encode(rhs))
  }
}
