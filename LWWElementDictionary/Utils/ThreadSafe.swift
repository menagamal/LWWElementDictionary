//
//  ThreadSafe.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 23/02/2025.
//

import Foundation

@propertyWrapper
class ThreadSafe<Value> {
    private var value: Value
    private let queue = DispatchQueue(label: "com.wrapper.threadSafe", attributes: .concurrent)

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.value = newValue
            }
        }
    }

     func mutate(_ mutation: (inout Value) -> Void) {
        queue.sync(flags: .barrier) {
            mutation(&value)
        }
    }
}
