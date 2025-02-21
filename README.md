# Live Merge CRDT App

## 📌 Overview
This project demonstrates the implementation of a **Last-Write-Wins Element Dictionary (LWW-Element-Dictionary)** using **Conflict-Free Replicated Data Types (CRDTs)**. The app simulates **real-time data merging** from distributed replicas and showcases how conflicts are resolved in a distributed system using timestamps.

## 🚀 Features
- **State-based LWW-Element-Dictionary** implementation
- **Thread-safe version** for concurrent operations
- **Live data merging simulation**
- **MVVM Architecture**
- **Comprehensive Unit Tests**

## 📂 Project Structure
```
├── LWWElementDictionary.swift       # Core CRDT implementation
├── ThreadSafeLWWElementDictionary.swift  # Thread-safe CRDT wrapper
├── LWWDictionaryViewModel.swift    # ViewModel for managing CRDT logic
├── ViewController.swift            # UI layer
├── Logger.swift                    # Simple logging utility
├── Tests/
│   ├── LWWElementDictionaryTests.swift  # Unit tests for dictionary logic
│   ├── ThreadSafeLWWElementDictionaryTests.swift  # Thread safety tests
│   ├── LWWDictionaryViewModelTests.swift  # ViewModel unit tests
└── README.md
```

## 📦 Installation
1. Clone this repository:
   ```sh
   git clone https://github.com/menagamal/LWWElementDictionary.git
   ```
2. Open the project in **Xcode**.
3. Run the app on a simulator or a real device.

## 🎮 Usage
- The app automatically starts **simulating real-time updates** to two replicas.
- These updates are merged periodically based on timestamp precedence.
- The UI updates dynamically to reflect the merged state.

## 🧪 Running Tests
To execute unit tests:
1. Open **Xcode**
2. Select **Product > Test** (⌘U) or run tests from the **Test Navigator**

## 🛠 Technologies Used
- **Swift**
- **UIKit**
- **XCTest** for unit testing
- **Grand Central Dispatch (GCD)** for thread safety

## 📖 CRDT Reference Material
For more information about **Conflict-Free Replicated Data Types (CRDTs)**, check out:
- [Wikipedia - CRDT](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type)
- [CRDT Notes](https://github.com/pfrazee/crdt_notes)
- [Technical Paper](https://hal.inria.fr/inria-00555588/PDF/techreport.pdf)

## 📌 Contribution
Contributions are welcome! If you’d like to improve this project:
1. Fork the repo
2. Create a new branch (`feature-branch`)
3. Commit changes
4. Submit a **Pull Request**

## 📜 License
This project is licensed under the **MIT License**.
