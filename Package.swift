// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Blockchain",
  dependencies: [
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "0.8.1")),
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "4.1.1")),
  ],
  targets: [
    .target(name: "Blockchain", dependencies: ["CryptoSwift", "RxSwift"]),
  ]
)
