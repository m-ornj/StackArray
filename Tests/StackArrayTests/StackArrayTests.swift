import Testing
@testable import StackArray

@Suite("StackArray Tests")
struct StackArrayTests {
    typealias Array64Byte<T> = StackArray<T, Buffer64Byte>
    
    @Test("Empty init and basic properties")
    func testInit() {
        let array = Array64Byte<Int>()
        #expect(array.isEmpty)
        #expect(array.count == 0)
        #expect(array.startIndex == 0)
        #expect(array.endIndex == 0)
    }
    
    @Test("Appending and subscripting")
    func testAppendAndAccess() {
        var array = Array64Byte<Int>()
        for i in 0..<8 {
            array.append(i)
        }
        #expect(array.count == 8)
        for i in 0..<8 {
            #expect(array[i] == i)
        }
    }
    
    @Test("Insert at index")
    func testInsert() {
        var array: Array64Byte<Int> = [1, 2, 3]
        array.insert(99, at: 1)
        #expect(array.count == 4)
        #expect(array[0] == 1)
        #expect(array[1] == 99)
        #expect(array[2] == 2)
        #expect(array[3] == 3)
    }
    
    @Test("Remove at index")
    func testRemove() {
        var array: Array64Byte<Int> = [10, 20, 30]
        let removed = array.remove(at: 1)
        #expect(removed == 20)
        #expect(array.count == 2)
        #expect(array[0] == 10)
        #expect(array[1] == 30)
    }

    @Test("Replace subrange with smaller slice")
    func testReplaceSubrangeShrink() {
        var array: Array64Byte<Int> = [0, 1, 2, 3]
        array.replaceSubrange(1..<3, with: [9])
        #expect(Array(array) == [0, 9, 3])
    }

    @Test("Replace subrange with equal size")
    func testReplaceSubrangeSameSize() {
        var array: Array64Byte<Int> = [0, 1, 2, 3]
        array.replaceSubrange(1..<3, with: [7, 8])
        #expect(array == [0, 7, 8, 3])
    }

    @Test("Replace subrange with empty")
    func testReplaceSubrangeRemove() {
        var array: Array64Byte<Int> = [10, 20, 30]
        array.replaceSubrange(0..<2, with: [])
        #expect(Array(array) == [30])
    }

    @Test("Collection conformance")
    func testCollectionFeatures() {
        let array: Array64Byte<String> = ["a", "b", "c"]
        let result = array.map { $0.uppercased() }.joined()
        #expect(result == "ABC")
    }
}

// Can't test fatalError yet :(
