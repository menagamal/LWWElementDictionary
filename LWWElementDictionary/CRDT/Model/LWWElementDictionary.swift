//
//  LWWElementDictionary.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 21/02/2025.
//

import Foundation

struct LWWElementDictionary<Key: Hashable, Value: Comparable> {

    /// Dictionary storing the value and its timestamp for additions/updates.
    private var addSet: [Key: (value: Value, timestamp: Date)] = [:]

    /// Dictionary storing the timestamp for removals.
    private var removeSet: [Key: Date] = [:]

    public init() {}

    // MARK: - Mutating Functions

    /// Adds or updates the value for the given key.
    mutating func set(key: Key, value: Value, timestamp: Date = Date()) {
        if let existing = addSet[key] {
            let latestTimestamp = max(existing.timestamp, timestamp)
            let latestValue = (existing.timestamp <= timestamp) ? value : existing.value
            addSet[key] = (value: latestValue, timestamp: latestTimestamp)
        } else {
            addSet[key] = (value: value, timestamp: timestamp)
        }
    }

    /// Removes the key from the dictionary.
    mutating func remove(key: Key, timestamp: Date = Date()) {
        removeSet[key] = max(removeSet[key] ?? timestamp, timestamp)
    }

    /// Merges another LWWElementDictionary into this one.
    mutating func merge(with other: LWWElementDictionary<Key, Value>) {
        for (key, otherAdd) in other.addSet {
            if let selfAdd = self.addSet[key] {
                let latestTimestamp = max(selfAdd.timestamp, otherAdd.timestamp)
                let latestValue = (selfAdd.timestamp == otherAdd.timestamp) ? max(selfAdd.value, otherAdd.value) : (latestTimestamp == selfAdd.timestamp ? selfAdd.value : otherAdd.value)

                if latestValue != selfAdd.value {
                    Logger.shared.log("Merge conflict for key '\(key)': '\(selfAdd.value)' vs '\(otherAdd.value)' at \(latestTimestamp). Winner: '\(latestValue)'")
                }

                self.addSet[key] = (value: latestValue, timestamp: latestTimestamp)
            } else {
                self.addSet[key] = otherAdd
            }
        }

        for (key, otherRemove) in other.removeSet {
            if let selfRemoveTimestamp = removeSet[key], otherRemove > selfRemoveTimestamp {
                Logger.shared.log("Key '\(key)' removed by merge. Latest timestamp: \(otherRemove)")
            }
            removeSet[key] = max(removeSet[key] ?? otherRemove, otherRemove)
        }
    }

    // MARK: - Retrieval Functions

    /// Looks up the value associated with the key.
    func lookup(key: Key) -> Value? {
        guard let addEntry = addSet[key] else { return nil }
        if let removeTimestamp = removeSet[key], removeTimestamp >= addEntry.timestamp {
            return nil
        }
        return addEntry.value
    }

    /// Returns the current state of the dictionary.
    func currentState() -> [Key: Value] {
        var result: [Key: Value] = [:]
        for (key, addEntry) in addSet where (removeSet[key] ?? Date.distantPast) < addEntry.timestamp {
            result[key] = addEntry.value
        }
        return result
    }
}
