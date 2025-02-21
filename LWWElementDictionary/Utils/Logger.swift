//
//  Logger.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 21/02/2025.
//

import Foundation

final class Logger {
    static let shared = Logger()
    private let logQueue = DispatchQueue(label: "com.example.LoggerQueue", qos: .utility)
    private(set) var logs: [String] = []

    private init() {}

    func log(_ message: String) {
        logQueue.async {
            let timestampedMessage = "[\(Date())] \(message)"
            self.logs.append(timestampedMessage)
            print(timestampedMessage)
        }
    }

    func getLogs() -> [String] {
        return logQueue.sync { logs }  // Ensures thread-safe read access
    }
}
