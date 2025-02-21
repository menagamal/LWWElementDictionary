//
//  ViewController.swift
//  LWWElementDictionary
//
//  Created by Mena Gamal on 21/02/2025.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, ViewModelDelegate {

    private let tableView = UITableView()
    private let viewModel = LWWDictionaryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Live Merge Operations"

        setupTableView()

        // Set ViewModel delegate
        viewModel.delegate = self
        viewModel.startSimulation()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }

    // MARK: - ViewModelDelegate

    func didUpdateData() {
        DispatchQueue.main.async {
            UIView.transition(with: self.tableView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: {
                self.tableView.reloadData()
            }, completion: nil)
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = viewModel.item(at: indexPath.row) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Key: \(item.key) → Value: \(item.value)"
        return cell
    }

    deinit {
        viewModel.stopSimulation()
    }
}
