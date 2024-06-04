//
//  TransactionListViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 04/06/24.
//

import UIKit
import FirebaseFirestore

class TransactionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var transactions: [Transaction] = []
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Transactions List"
        navigationController?.navigationBar.backgroundColor = .black
        setupTableView()
        setupRefreshControl()
        fetchTransactions()
    }

    func setupTableView() {
        tableView = UITableView(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionViewCell.self, forCellReuseIdentifier: "TransactionViewCell")
        self.view.addSubview(tableView)
    }

    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        fetchTransactions()
    }

    func fetchTransactions() {
        let db = Firestore.firestore()
        db.collection("Transactions").order(by: "timestamp", descending: true).getDocuments { (querySnapshot, error) in
            self.refreshControl.endRefreshing() // Stop the refresh control animation

            if let error = error {
                print("Error getting transactions: \(error)")
            } else {
                self.transactions = querySnapshot?.documents.compactMap { document -> Transaction? in
                    let data = document.data()
                    return Transaction(transactionType: data["transactionType"] as! String,
                                       participantName: data["participantName"] as! String,
                                       transactionDetails: data["transactionDetails"] as! [String: Any],
                                       timestamp: data["timestamp"] as! Timestamp)
                } ?? []
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionViewCell", for: indexPath) as! TransactionViewCell
        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}
