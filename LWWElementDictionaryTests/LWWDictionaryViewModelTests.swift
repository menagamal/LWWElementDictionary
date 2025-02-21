//
//  LWWDictionaryViewModelTests.swift
//  LWWElementDictionaryTests
//
//  Created by Mena Gamal on 21/02/2025.
//

import XCTest
@testable import LWWElementDictionary

final class LWWDictionaryViewModelTests: XCTestCase {

    var viewModel: LWWDictionaryViewModel!
    var delegateMock: ViewModelDelegateMock!

    override func setUp() {
        super.setUp()
        viewModel = LWWDictionaryViewModel()
        delegateMock = ViewModelDelegateMock()
        viewModel.delegate = delegateMock
    }

    override func tearDown() {
        viewModel = nil
        delegateMock = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testViewModelStartsEmpty() {
        XCTAssertEqual(viewModel.numberOfRows(), 0, "Initial state should be empty")
    }

    // MARK: - Add & Lookup Tests

    func testAddingSingleItem() {
        let key = 1
        let value = "TestValue"
        let timestamp = Date()

        viewModel.replica1.set(key: key, value: value, timestamp: timestamp)

        XCTAssertEqual(viewModel.numberOfRows(), 1, "One item should be added")

        let item = viewModel.item(at: 0)
        XCTAssertEqual(item?.key, key)
        XCTAssertEqual(item?.value, value)
    }

    func testAddingMultipleItems() {
        let timestamp = Date()

        viewModel.replica1.set(key: 1, value: "A", timestamp: timestamp)
        viewModel.replica1.set(key: 2, value: "B", timestamp: timestamp)

        XCTAssertEqual(viewModel.numberOfRows(), 2, "Two items should be added")
    }

    // MARK: - Merge Tests

    func testMergeUpdatesLatestValue() {
        let timestamp1 = Date(timeIntervalSince1970: 1000)
        let timestamp2 = Date(timeIntervalSince1970: 2000)

        viewModel.replica1.set(key: 1, value: "OldValue", timestamp: timestamp1)
        viewModel.replica2.set(key: 1, value: "NewValue", timestamp: timestamp2)

        viewModel.replica1.mergeSync(with: viewModel.replica2)

        let item = viewModel.item(at: 0)
        XCTAssertEqual(item?.value, "NewValue", "Newer timestamp should override old value")
    }

    func testMergeWithRemoval() {
        let timestamp1 = Date(timeIntervalSince1970: 1000)
        let timestamp2 = Date(timeIntervalSince1970: 2000)

        viewModel.replica1.set(key: 1, value: "Exists", timestamp: timestamp1)
        viewModel.replica2.remove(key: 1, timestamp: timestamp2)

        viewModel.replica1.mergeSync(with: viewModel.replica2)

        XCTAssertEqual(viewModel.numberOfRows(), 0, "Item should be removed after merge")
    }

    // MARK: - Simulation Tests

    func testSimulationUpdatesData() {
        let expectation = XCTestExpectation(description: "Simulation should trigger UI update")

        delegateMock.onUpdate = {
            expectation.fulfill()
        }

        viewModel.startSimulation()

        wait(for: [expectation], timeout: 12.0)

        XCTAssertGreaterThan(viewModel.numberOfRows(), 0, "Simulation should add elements")
    }

    func testSimulationStopsAtLimit() {
        for i in 0...20 {
            viewModel.replica1.set(key: i, value: "Value_\(i)", timestamp: Date())
        }

        viewModel.startSimulation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
            XCTAssertEqual(self.viewModel.numberOfRows(), 21, "Simulation should stop when limit is reached")
        }
    }

    // MARK: - Delegate Tests

    func testDelegateReceivesUpdate() {
        let expectation = XCTestExpectation(description: "Delegate should be notified of updates")

        delegateMock.onUpdate = {
            expectation.fulfill()
        }

        viewModel.replica1.set(key: 1, value: "UpdateTest", timestamp: Date())
        viewModel.delegate?.didUpdateData()

        wait(for: [expectation], timeout: 1.0)
    }
}
