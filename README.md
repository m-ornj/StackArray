# StackArray

A fixed-capacity, stack-allocated array type in Swift - with the familiar feel of a standard array, but with no heap allocations.

`StackArray` behaves like a regular Swift array in usage and protocol conformance, while ensuring that all memory stays on the stack. It's useful in situations where dynamic memory allocation is impossible, undesirable, or needs to be tightly controlled - such as interoperability with C, deterministic memory layout, embedded systems, or data-driven designs.

### Features

- Stack allocated.
- Fixed compile-time capacity.
- Behaves like a standard array in usage and API.
- Easily extended with custom buffer sizes.

### Buffer Types & Capacity

`StackArray<Element, Buffer>` stores elements directly in stack-allocated memory. The `Buffer` type defines how much space is reserved, typically using a fixed-size tuple.

Swift doesn't currently support fixed-size inline arrays or compile-time evaluated sizes, so tuples are the most reliable way to reserve a known amount of stack memory.

This package includes some pre-defined buffer types from 64 to 1024 bytes:

```swift
typealias Buffer64Byte = (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)
typealias Buffer128Byte = (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64,
                           UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)
// and so on...
```

You can also define your own buffer types to tune memory layout as needed:

```swift
typealias MyCustomBuffer = (UInt64, UInt64, UInt64, UInt16) // 208 bits = 26 bytes
var alphabet = StackArray<Bool, MyCustomBuffer>()           // can fit 26 booleans
```

### Usage

```swift
import StackArray

var numbers: StackArray<Int, Buffer128Byte> = [0, 1, 2]

// Append elements
numbers.append(3)
numbers.append(contentsOf: [6, 5, 4])

// Insert elements
numbers.insert(7, at: 3)
numbers.insert(contentsOf: [8, 9], at: 4)

// Modify elements
numbers[0] = 9

// Remove elements
numbers.removeFirst()
numbers.removeLast()
numbers.removeAll { $0 % 2 == 0 }

// Iterate
for n in numbers {
  print(n)
}

// Sort
numbers.sort()

print("Sorted:", numbers)
```
