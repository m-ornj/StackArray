fileprivate func zeroInitialized<T: BitwiseCopyable>() -> T {
    withUnsafeTemporaryAllocation(byteCount: MemoryLayout<T>.size, alignment: MemoryLayout<T>.alignment) {
        $0.initializeMemory(as: UInt8.self, repeating: 0)
        guard let baseAddress = $0.baseAddress else {
            fatalError("Failed to allocate temporary memory for \(T.self)")
        }
        return baseAddress.assumingMemoryBound(to: T.self).move()
    }
}

public struct StackArray<Element, Buffer: BitwiseCopyable> {
    static var capacity: Int { MemoryLayout<Buffer>.size / MemoryLayout<Element>.stride }
    public var capacity: Int { Self.capacity }
    
    public var buffer: Buffer = zeroInitialized()
    public var count: Int = 0
    
    public init() {}
}

extension StackArray: MutableCollection, RandomAccessCollection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public subscript(position: Int) -> Element {
        get {
            guard position >= 0 && position < count else { fatalError("Index out of range") }
            return withUnsafePointer(to: buffer) {
                $0.withMemoryRebound(to: Element.self, capacity: Self.capacity) { buffer in
                    buffer[position]
                }
            }
        }
        mutating set(newValue) {
            guard position >= 0 && position < count else { fatalError("Index out of range") }
            withUnsafeMutablePointer(to: &buffer) {
                $0.withMemoryRebound(to: Element.self, capacity: Self.capacity) { buffer in
                    buffer[position] = newValue
                }
            }
        }
    }
}

extension StackArray: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Element == Element {
        let oldCount = subrange.count
        let newCount = newElements.count
        let delta = newCount - oldCount

        guard count + delta <= Self.capacity else {
            fatalError("Exceeding maximum capacity of \(Self.capacity) elements")
        }

        let tailStart = subrange.upperBound
        let tailCount = count - tailStart

        withUnsafeMutablePointer(to: &buffer) {
            $0.withMemoryRebound(to: Element.self, capacity: Self.capacity) { buffer in
                // Shift tail if needed
                let srcIndex = tailStart
                let dstIndex = tailStart + delta
                if delta < 0 {
                    for i in 0..<tailCount {
                        buffer[dstIndex + i] = buffer[srcIndex + i]
                    }
                } else if delta > 0 {
                    for i in (0..<tailCount).reversed() {
                        buffer[dstIndex + i] = buffer[srcIndex + i]
                    }
                }

                // Copy in new elements
                var i = subrange.lowerBound
                for element in newElements {
                    buffer[i] = element
                    i += 1
                }
            }
        }
        count += delta
    }

    public mutating func reserveCapacity(_ n: Int) {
        fatalError("reserveCapacity(_:) is not supported for StackArray")
    }
}

extension StackArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension StackArray where Element: Equatable {
    public static func == (lhs: StackArray, rhs: ArraySlice<Element>) -> Bool {
        guard lhs.count == rhs.count else { return false }
        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] {
                return false
            }
        }
        return true
    }
}

extension StackArray: CustomStringConvertible {
    public var description: String {
        var result = "["
        var first = true
        for element in self {
            if !first {
                result += ", "
            }
            result += String(describing: element)
            first = false
        }
        result += "]"
        return result
    }
}

extension StackArray: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = "["
        var first = true
        for element in self {
            if !first {
                result += ", "
            }
            result += String(reflecting: element)
            first = false
        }
        result += "]"
        return result
    }
}
