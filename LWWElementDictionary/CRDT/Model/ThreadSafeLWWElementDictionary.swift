//
//  ThreadSafeLWWElementDictionary.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 21/02/2025.
//

import Foundation
final class ThreadSafeLWWElementDictionary<Key: Hashable, Value: Comparable> {

    @ThreadSafe private var crdt: LWWElementDictionary<Key, Value>

    init() {
        _crdt = ThreadSafe(wrappedValue: LWWElementDictionary<Key, Value>())
    }

    func lookup(key: Key) -> Value? {
        return crdt.lookup(key: key)
    }

    func set(key: Key, value: Value, timestamp: Date = Date()) {
        _crdt.mutate { crdt in
            crdt.set(key: key, value: value, timestamp: timestamp)
            Logger.shared.log("Set key \(key) to value '\(value)' at \(timestamp)")
        }
    }

    func remove(key: Key, timestamp: Date = Date()) {
        _crdt.mutate { crdt in
            crdt.remove(key: key, timestamp: timestamp)
            Logger.shared.log("Removed key \(key) at \(timestamp)")
        }
    }

    func merge(with other: ThreadSafeLWWElementDictionary<Key, Value>, completion: (() -> Void)? = nil) {
        let otherCRDT = other.getCRDT()
        _crdt.mutate { crdt in
            crdt.merge(with: otherCRDT)
            Logger.shared.log("Merged asynchronously with other CRDT. New state: \(crdt.currentState())")
            completion?()
        }
    }

    func mergeSync(with other: ThreadSafeLWWElementDictionary<Key, Value>) {
        let otherCRDT = other.getCRDT()
        _crdt.mutate { crdt in
            crdt.merge(with: otherCRDT)
            Logger.shared.log("Merged synchronously with other CRDT. New state: \(crdt.currentState())")
        }
    }

    fileprivate func getCRDT() -> LWWElementDictionary<Key, Value> {
        return crdt
    }

    func currentState() -> [Key: Value] {
        return crdt.currentState()
    }
}
