import Foundation

@inline(__always)
func random<Bound>() -> Bound where Bound: FixedWidthInteger & SignedInteger {
  if MemoryLayout<Bound>.size >= MemoryLayout<UInt32>.size {
    return Bound(arc4random())
  } else {
    return Bound(arc4random() % UInt32(Bound.max))
  }
}

@inline(__always)
func random<Bound>(_ range: Range<Bound>) -> Bound where Bound: FixedWidthInteger & SignedInteger {
  return random() % (range.upperBound - range.lowerBound) + range.lowerBound
}

@inline(__always)
func random<Bound>(_ range: CountableRange<Bound>) -> Bound where Bound: FixedWidthInteger & SignedInteger {
  return random() % (range.upperBound - range.lowerBound) + range.lowerBound
}

@inline(__always)
func random<Bound>(_ range: ClosedRange<Bound>) -> Bound where Bound: FixedWidthInteger & SignedInteger {
  return random() % (range.upperBound - range.lowerBound) + range.lowerBound
}

@inline(__always)
func random<Bound>(_ range: CountableClosedRange<Bound>) -> Bound where Bound: FixedWidthInteger & SignedInteger {
  return random() % (range.upperBound - range.lowerBound) + range.lowerBound
}

@inline(__always)
func choice<C: Collection>(_ collection: C) -> C.Element? where C.Index == Int {
  guard !collection.isEmpty else { return nil }
  let index = random(collection.startIndex...collection.endIndex)
  return collection[index]
}

