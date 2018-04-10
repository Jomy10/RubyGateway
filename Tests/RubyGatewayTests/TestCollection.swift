//
//  TestThreads.swift
//  RubyGatewayTests
//
//  Distributed under the MIT license, see LICENSE
//

import XCTest
import RubyGateway
import Foundation

class TestCollection: XCTestCase {

    // check it basically works
    func testSequence() {
        let arr: RbObject = [1, 2, 3, 4]
        let sum = arr.collection.map { $0 * 2 }.reduce(0) { $0 + $1 }
        XCTAssertEqual(20, Int(sum))
    }

    // check mutable stuff works OK
    func testMutable() {
        let arr: RbObject = [4, 3, 2, 1]
        var coll = arr.collection
        coll[2] = 8
        XCTAssertEqual([4, 3, 8, 1], Array<Int>(arr))
        coll[0..<2].sort()
        XCTAssertEqual([3, 4, 8, 1], Array<Int>(arr))
    }

    // check range setter passed thru OK, same cardinality
    func testRangeReplace() {
        let arr: RbObject = [1, 2, 3, 4]
        var coll = arr.collection

        coll.replaceSubrange(0..<2, with: [8, 9])
        XCTAssertEqual([8, 9, 3, 4], Array<Int>(arr))
    }

    // check range setter passed thru OK, > cardinality
    func testRangeReplaceMore() {
        let arr: RbObject = [1, 2, 3, 4]
        var coll = arr.collection

        coll.replaceSubrange(0...1, with: [8, 9, 10, 11])
        XCTAssertEqual([8, 9, 10, 11, 3, 4], Array<Int>(arr))
    }

    // check range setter passed thru OK, < cardinality
    func testRangeReplaceLess() {
        let arr: RbObject = [1, 2, 3, 4]
        var coll = arr.collection

        coll.replaceSubrange(0...1, with: [5])
        XCTAssertEqual([5, 3, 4], Array<Int>(arr))

        coll.removeSubrange(1...2)
        XCTAssertEqual([5], Array<Int>(arr))
    }

    // constructivist API, can't avoid supporting from protocols
    func testConstructivist() {
        let el = "Fish"
        let count = 3
        let coll = RbObjectCollection(repeating: RbObject(el), count: count)
        XCTAssertEqual(Array(repeating: el, count: count), Array<String>(coll.rubyObject))
    }

    static var allTests = [
        ("testSequence", testSequence),
        ("testMutable", testMutable),
        ("testRangeReplace", testRangeReplace),
        ("testRangeReplaceMore", testRangeReplaceMore),
        ("testRangeReplaceLess", testRangeReplaceLess),
        ("testConstructivist", testConstructivist)
    ]
}
