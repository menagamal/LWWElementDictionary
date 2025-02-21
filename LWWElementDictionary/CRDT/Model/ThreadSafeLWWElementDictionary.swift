//
//  ThreadSafeLWWElementDictionary.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 21/02/2025.
//

import Foundation
final class ThreadSafeLWWElementDictionary<Key: Hashable, Value: Comparable> {

    private var crdt = LWWElementDictionary<Key, Value>()
    private let queue = DispatchQueue(label: "com.example.LWWElementDictionaryQueue", attributes: .concurrent)

    func lookup(key: Key) -> Value? {
        return queue.sync { crdt.lookup(key: key) }
    }

    func set(key: Key, value: Value, timestamp: Date = Date()) {
        queue.async(flags: .barrier) {
            self.crdt.set(key: key, value: value, timestamp: timestamp)
            Logger.shared.log("Set key \(key) to value '\(value)' at \(timestamp)")
        }
    }

    func remove(key: Key, timestamp: Date = Date()) {
        queue.async(flags: .barrier) {
            self.crdt.remove(key: key, timestamp: timestamp)
            Logger.shared.log("Removed key \(key) at \(timestamp)")
        }
    }

    func merge(with other: ThreadSafeLWWElementDictionary<Key, Value>, completion: (() -> Void)? = nil) {
        let otherCRDT = other.getCRDT()
        queue.async(flags: .barrier) {
            self.crdt.merge(with: otherCRDT)
            Logger.shared.log("Merged asynchronously with other CRDT. New state: \(self.crdt.currentState())")
            completion?()
        }
    }

    func mergeSync(with other: ThreadSafeLWWElementDictionary<Key, Value>) {
        let otherCRDT = other.getCRDT()
        queue.sync(flags: .barrier) {
            self.crdt.merge(with: otherCRDT)
            Logger.shared.log("Merged synchronously with other CRDT. New state: \(self.crdt.currentState())")
        }
    }

    fileprivate func getCRDT() -> LWWElementDictionary<Key, Value> {
        return queue.sync { self.crdt }
    }

    func currentState() -> [Key: Value] {
        return queue.sync { self.crdt.currentState() }
    }
}


