import Foundation
import RxSwift

defer { RunLoop.main.run() }

let network = Network()
let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

let nodes: [Node] = [
  try .init(network: network, scheduler: scheduler, address: "1.1.1.1"),
  try .init(network: network, scheduler: scheduler, address: "2.2.2.2"),
  try .init(network: network, scheduler: scheduler, address: "3.3.3.3"),
]
let me = try KeyPair(
  privateKey: "MIIEpQIBAAKCAQEA2elqN1xvPbNpjh0zoeT/H644L7KMKFpv4ANwnNudo6J4fIuTlv3hIe/OPK06g+WdGz/SYY8mWrxEJ0m8ttXv3voHAIZZug09p/yku76r6RxnGq/rDdEfYRK7cFQhl3O6rKVyhmtt25FvP1dfIUH+yxal/9enBr6E/+J2gOMYCZZ79kXabNKxSHFYUTVrFzkzBO97EzYufHJjfSdkjONMiH4gnzSjCH8kDGtO+FH21s9d1H6cer4AoutaE8r1QFco8HbnnDEnNYxf691+V74fNHUVsURxC57Oy611FjAo8gyjbZESK3s1gWH3lCj2OyIda84P00kUD2UaWtmHiKvKAwIDAQABAoIBAB2VK39ChDOLJLxPSJAk52GkpCoNgiuEQ4XU0bfptJffWZ4G0M2Bv8t8o7HnDneTd2WYn3XxGhLdVh9DSmRD3OGXbdXrZ0jzvTgN+0slkm7+FR0xXqasiicChQG12i2WX3RKraaD9REGyGR/9wEr1Ww6seRuoVUwDhwy4UWUDtJWJF0o+4ei1Tm5Q5u51JWcLwE/KiZ7G0xnEgc+SRU61lZyzQaQvOKQw1fv3ZuLzAKgfGsXVAn82JrHI/cswr8iHuSXNxdFpZvYITLeuYNjfTm6R1SEG8gSyDsDznCHSRRIrUFLy4l6KxFKR/IzjPCIvj32TCAC4cn61lpg99dwY2ECgYEA+LH9Q4EQOvLoKqcsh9Cb5WP6C2yv+5dsArxpgjJqa4Qf1xJBttSxKGF1La2jf+0iaAFvO+vd1sveNBrbweP6HqrSU+Gt0CrHuBL9sqro9uIYJQf4OGWvfOoNppOrGyqq29fgeFujw5XyHSWZgyljsVo6y6Eoy3eGvSCC4rZn23MCgYEA4E/0qlqsBdARs0LPiGVLQGjCPHjhtKZJnBqmkW1DhCCQBgIQmq14WuOGTLMPng/JW8+OlQhGfp5JwNLYh3gxA/qZDEbK51tmVYaGpL2xqWxcKVn8E+16mtQg2AY5ns+W6ML6cGYMi7ARENRC4OVw/5mhemWLafmJlk8L2sKp0zECgYEAlgRgHxFCphyS+e/AB+lJsRUe5zdX7O9Jg1j+WEBrO5IG1ui3ZT9l4lLvqW892lREVfLPk5jTR9fQoSO2fn40Cb3HhDv1akX0FdC24skAILUAFY56KCMGudZCB8K6C3gwes79I/07iybvVq+wq5MTBQ/FucHsZtgiGgH7kiCwA4sCgYEAvy5GeJ9ZOIcTXvbVjQnQbnAbBJF+xYpo+JyaVR6MSeO6/PPrlPm+t7BuOZbv+6a21wJ7Irhv5OEiOS87j5K4LAz9PsJjk3aKLODAh06KSr1pe3EPcSiZs7aS26vKlnmVxILSEtRXYwNIOFDBQ48qlR8qyvgbL9KYGrz6fJQnTDECgYEAxmtMc7qPDhgBX/y1uwVdPPY/taOLZhMeRpGArMG0JYvxRPHchfTwfkkPJfaIY2ybgXzwdPS57huoswjYWXUsmozR2F9qEjpBAK9uFv7kkm5O5aMeR3nUzk5svHxaDYhfPm5htXC5dgDJhqN0sSNtgkcfHyrycZWwtu3KoaQdVRk=",
  publicKey: "MIIBCgKCAQEA2elqN1xvPbNpjh0zoeT/H644L7KMKFpv4ANwnNudo6J4fIuTlv3hIe/OPK06g+WdGz/SYY8mWrxEJ0m8ttXv3voHAIZZug09p/yku76r6RxnGq/rDdEfYRK7cFQhl3O6rKVyhmtt25FvP1dfIUH+yxal/9enBr6E/+J2gOMYCZZ79kXabNKxSHFYUTVrFzkzBO97EzYufHJjfSdkjONMiH4gnzSjCH8kDGtO+FH21s9d1H6cer4AoutaE8r1QFco8HbnnDEnNYxf691+V74fNHUVsURxC57Oy611FjAo8gyjbZESK3s1gWH3lCj2OyIda84P00kUD2UaWtmHiKvKAwIDAQAB"
)

let users: [KeyPair] = [me] + (0..<5).flatMap { _ in try? KeyPair() }

_ = Observable<Int>.interval(3, scheduler: scheduler)
  .subscribe(onNext: { _ in
    guard let node = choice(nodes) else { return }
    guard let from = choice(users) else { return }
    guard let to = choice(users) else { return }

    try? node.send(
      amount: Double(random(0..<100)),
      from: from,
      to: Blockchain.hash(to.publicKey.stringValue)
    )
  })
