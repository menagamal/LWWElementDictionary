//
//  ThreadSafeLWWElementDictionaryTests.swift
//  LWWElementDictionaryTests
//
//  Created by Mena Gamal on 21/02/2025.
//

import XCTest
import Dispatch
@testable import LWWElementDictionary

final class ThreadSafeLWWElementDictionaryTests: XCTestCase {
    func testLargeScaleMergePerformance() {
           let dict1 = ThreadSafeLWWElementDictionary<Int, String>()
           let dict2 = ThreadSafeLWWElementDictionary<Int, String>()

           let numEntries = 100_000

           for i in 0..<numEntries {
               dict1.set(key: i, value: "dict1-\(i)", timestamp: Date(timeIntervalSince1970: TimeInterval(i)))
               dict2.set(key: i, value: "dict2-\(i)", timestamp: Date(timeIntervalSince1970: TimeInterval(i + 1)))
           }

           measure {
               dict1.mergeSync(with: dict2)
           }

           for i in 0..<numEntries {
               XCTAssertEqual(dict1.lookup(key: i), "dict2-\(i)")
           }
       }

       func testConcurrentLargeScaleMerge() {
           let dict1 = ThreadSafeLWWElementDictionary<Int, String>()
           let dict2 = ThreadSafeLWWElementDictionary<Int, String>()

           let numEntries = 100_000
           let queue = DispatchQueue.global(qos: .userInitiated)
           let expectation = XCTestExpectation(description: "Concurrent Merge")

           DispatchQueue.concurrentPerform(iterations: numEntries) { i in
               dict1.set(key: i, value: "dict1-\(i)", timestamp: Date(timeIntervalSince1970: TimeInterval(i)))
               dict2.set(key: i, value: "dict2-\(i)", timestamp: Date(timeIntervalSince1970: TimeInterval(i + 1)))
           }

           queue.async {
               dict1.mergeSync(with: dict2)
               expectation.fulfill()
           }

           wait(for: [expectation], timeout: 5.0)

           for i in 0..<numEntries {
               XCTAssertEqual(dict1.lookup(key: i), "dict2-\(i)")
           }
       }

       func testAddAndLookup() {
           let dict = ThreadSafeLWWElementDictionary<String, String>()
           dict.set(key: "key1", value: "value1", timestamp: Date(timeIntervalSince1970: 1))
           dict.set(key: "key2", value: "value2", timestamp: Date(timeIntervalSince1970: 2))

           XCTAssertEqual(dict.lookup(key: "key1"), "value1")
           XCTAssertEqual(dict.lookup(key: "key2"), "value2")
       }

       func testRemove() {
           let dict = ThreadSafeLWWElementDictionary<String, String>()
           dict.set(key: "key1", value: "value1", timestamp: Date(timeIntervalSince1970: 1))
           dict.remove(key: "key1", timestamp: Date(timeIntervalSince1970: 2))

           XCTAssertNil(dict.lookup(key: "key1"))
       }

       func testConcurrentAccess() {
           let dict = ThreadSafeLWWElementDictionary<String, String>()
           let queue = DispatchQueue.global(qos: .userInteractive)
           let expectation = XCTestExpectation(description: "Concurrent updates")

           DispatchQueue.concurrentPerform(iterations: 100) { i in
               dict.set(key: "key", value: "value\(i)", timestamp: Date(timeIntervalSince1970: TimeInterval(i)))
           }

           queue.async {
               expectation.fulfill()
           }

           wait(for: [expectation], timeout: 2.0)
           XCTAssertNotNil(dict.lookup(key: "key"))
       }

       func testConcurrentReads() {
           let dict = ThreadSafeLWWElementDictionary<String, String>()
           dict.set(key: "sharedKey", value: "initialValue", timestamp: Date(timeIntervalSince1970: 1))

           let queue = DispatchQueue.global(qos: .userInteractive)
           let expectation = XCTestExpectation(description: "Concurrent Reads")

           DispatchQueue.concurrentPerform(iterations: 50) { _ in
               XCTAssertNotNil(dict.lookup(key: "sharedKey"))
           }

           queue.async {
               expectation.fulfill()
           }

           wait(for: [expectation], timeout: 2.0)
       }

       func testMerge() {
           let dict1 = ThreadSafeLWWElementDictionary<String, String>()
           let dict2 = ThreadSafeLWWElementDictionary<String, String>()

           dict1.set(key: "key", value: "oldValue", timestamp: Date(timeIntervalSince1970: 1))
           dict2.set(key: "key", value: "newValue", timestamp: Date(timeIntervalSince1970: 2))

           dict1.mergeSync(with: dict2)

           XCTAssertEqual(dict1.lookup(key: "key"), "newValue")
       }

       func testMergeWithRemoveConflict() {
           let dict1 = ThreadSafeLWWElementDictionary<String, String>()
           let dict2 = ThreadSafeLWWElementDictionary<String, String>()

           dict1.set(key: "key", value: "someValue", timestamp: Date(timeIntervalSince1970: 1))
           dict2.remove(key: "key", timestamp: Date(timeIntervalSince1970: 2))

           dict1.mergeSync(with: dict2)

           XCTAssertNil(dict1.lookup(key: "key"))
       }
}
