//
//  LWWElementDictionaryTests.swift
//  LWWElementDictionaryTests
//
//  Created by Mena Gamal on 21/02/2025.
//

import XCTest
@testable import LWWElementDictionary

final class LWWElementDictionaryTests: XCTestCase {

    func testAddingElement() {
         var dict = LWWElementDictionary<String, Int>()
         dict.set(key: "A", value: 10)

         XCTAssertEqual(dict.lookup(key: "A"), 10)
     }

     func testUpdatingElementWithNewerTimestamp() {
         var dict = LWWElementDictionary<String, Int>()
         let oldTimestamp = Date(timeIntervalSinceNow: -1000)
         let newTimestamp = Date()

         dict.set(key: "A", value: 10, timestamp: oldTimestamp)
         dict.set(key: "A", value: 20, timestamp: newTimestamp)

         XCTAssertEqual(dict.lookup(key: "A"), 20)
     }

     func testUpdatingElementWithOlderTimestamp() {
         var dict = LWWElementDictionary<String, Int>()
         let oldTimestamp = Date(timeIntervalSinceNow: -1000)
         let newTimestamp = Date()

         dict.set(key: "A", value: 20, timestamp: newTimestamp)
         dict.set(key: "A", value: 10, timestamp: oldTimestamp)

         XCTAssertEqual(dict.lookup(key: "A"), 20)
     }

     func testRemovingElement() {
         var dict = LWWElementDictionary<String, Int>()
         dict.set(key: "A", value: 10)
         dict.remove(key: "A")

         XCTAssertNil(dict.lookup(key: "A"))
     }

     func testRemovingElementWithOlderTimestamp() {
         var dict = LWWElementDictionary<String, Int>()
         let oldTimestamp = Date(timeIntervalSinceNow: -1000)
         let newTimestamp = Date()

         dict.set(key: "A", value: 10, timestamp: newTimestamp)
         dict.remove(key: "A", timestamp: oldTimestamp)

         XCTAssertEqual(dict.lookup(key: "A"), 10)
     }

     func testRemovingElementWithNewerTimestamp() {
         var dict = LWWElementDictionary<String, Int>()
         let oldTimestamp = Date(timeIntervalSinceNow: -1000)
         let newTimestamp = Date()

         dict.set(key: "A", value: 10, timestamp: oldTimestamp)
         dict.remove(key: "A", timestamp: newTimestamp)

         XCTAssertNil(dict.lookup(key: "A"))
     }

     func testMergeDictionaries() {
         var dict1 = LWWElementDictionary<String, Int>()
         var dict2 = LWWElementDictionary<String, Int>()

         let timestamp1 = Date(timeIntervalSinceNow: -1000)
         let timestamp2 = Date()

         dict1.set(key: "A", value: 10, timestamp: timestamp1)
         dict2.set(key: "A", value: 20, timestamp: timestamp2)

         dict1.merge(with: dict2)

         XCTAssertEqual(dict1.lookup(key: "A"), 20)
     }

     func testMergeDictionariesWithRemoval() {
         var dict1 = LWWElementDictionary<String, Int>()
         var dict2 = LWWElementDictionary<String, Int>()

         let timestamp1 = Date(timeIntervalSinceNow: -1000)
         let timestamp2 = Date()

         dict1.set(key: "A", value: 10, timestamp: timestamp1)
         dict2.remove(key: "A", timestamp: timestamp2)

         dict1.merge(with: dict2)

         XCTAssertNil(dict1.lookup(key: "A"))
     }

     func testCurrentState() {
         var dict = LWWElementDictionary<String, Int>()
         dict.set(key: "A", value: 10)
         dict.set(key: "B", value: 20)
         dict.remove(key: "A")

         let state = dict.currentState()

         XCTAssertEqual(state.count, 1)
         XCTAssertEqual(state["B"], 20)
         XCTAssertNil(state["A"])
     }

    func testIdenticalTimestampsTieBreaking() {
        var dict = LWWElementDictionary<String, String>()
        let timestamp = Date()
        dict.set(key: "a", value: "apple", timestamp: timestamp)
        dict.set(key: "a", value: "banana", timestamp: timestamp)

        XCTAssertEqual(dict.lookup(key: "a"), "banana", "Tie should be broken by lexicographical order")
    }

    func testClockDriftHandling() {
        var dict1 = LWWElementDictionary<String, String>()
        var dict2 = LWWElementDictionary<String, String>()

        let t1 = Date(timeIntervalSince1970: 1000)
        let t2 = Date(timeIntervalSince1970: 999)  // Older but from another replica

        dict1.set(key: "x", value: "value1", timestamp: t1)
        dict2.set(key: "x", value: "value2", timestamp: t2)

        dict1.merge(with: dict2)

        XCTAssertEqual(dict1.lookup(key: "x"), "value1", "Latest timestamp should always win")
    }
}
