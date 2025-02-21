//
//  LWWDictionaryViewModel.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 21/02/2025.
//

import Foundation

protocol ViewModelDelegate: AnyObject {
    func didUpdateData()
}

final class LWWDictionaryViewModel {

    // Two thread-safe replicas using Int keys and String values.
    let replica1 = ThreadSafeLWWElementDictionary<Int, String>()
    let replica2 = ThreadSafeLWWElementDictionary<Int, String>()

    private var simulationTimer: Timer?
    private var mergedKeys: [Int] = []

    weak var delegate: ViewModelDelegate?

    init() {}

    // MARK: - Data Access

    func numberOfRows() -> Int {
        return replica1.currentState().count
    }

    func item(at index: Int) -> (key: Int, value: String)? {
        let state = replica1.currentState()
        let sortedKeys = state.keys.sorted()
        guard index < sortedKeys.count else { return nil }
        let key = sortedKeys[index]
        return (key, state[key] ?? "N/A")
    }

    // MARK: - Simulation Logic

    func startSimulation() {
        simulationTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                               target: self,
                                               selector: #selector(simulateMerge),
                                               userInfo: nil,
                                               repeats: true)
    }

    func stopSimulation() {
        simulationTimer?.invalidate()
    }

    @objc private func simulateMerge() {
        if replica1.currentState().count > 20 {
            stopSimulation()
            return
        }

        let now = Date()
        let randomKey = Int.random(in: 0...20)
        Logger.shared.log("Simulating update for key \(randomKey)")

        let valueForReplica1 = "Rep1_\(Int.random(in: 100...999))"
        let valueForReplica2 = "Rep2_\(Int.random(in: 1000...9999))"

        // Update replicas with slight timestamp differences
        replica1.set(key: randomKey, value: valueForReplica1, timestamp: now)
        replica2.set(key: randomKey, value: valueForReplica2, timestamp: now.addingTimeInterval(0.1))

        // Simulate network delay before merging.
        let simulatedNetworkDelay = Double.random(in: 0.5...1.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedNetworkDelay) {
            self.replica1.mergeSync(with: self.replica2)

            // Update sorted keys
            let state = self.replica1.currentState()
            self.mergedKeys = state.keys.sorted()

            // Notify the delegate to refresh UI
            self.delegate?.didUpdateData()
        }
    }
}
