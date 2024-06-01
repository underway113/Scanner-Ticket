//
//  ListViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import FirebaseFirestore
import UIKit

class ListViewController: UIViewController {
    public var currentURLIndex: Int = 0
    let db = Firestore.firestore()
    var participants: [String: Participant] = [:]
    var filteredParticipants: [String: Participant] = [:]

    var tableView = UITableView()
    var searchBar = UISearchBar()
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchBar()
        setupTableView()
        fetchParticipants()
    }

    private func setupView() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else {
            self.navigationItem.title = "ERROR"
            return
        }
        title = ticketType.title
        view.backgroundColor = ticketType.backgroundColor
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(ParticipantTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func fetchParticipants() {
        activityIndicator.startAnimating()
        db.collection("Participants")
            .order(by: "name")
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                if let error = error {
                    self.showAlert(message: "Error fetching participants: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents")
                    return
                }

                self.participants = documents.reduce(into: [String: Participant]()) { (dict, document) in
                    let data = document.data()
                    if let name = data["name"] as? String,
                       let participantKit = data["participantKit"] as? Bool,
                       let entry = data["entry"] as? Bool,
                       let mainFood = data["mainFood"] as? Bool,
                       let snack = data["snack"] as? Bool {
                        let participant = Participant(documentID: document.documentID, name: name, participantKit: participantKit, entry: entry, mainFood: mainFood, snack: snack)
                        dict[document.documentID] = participant
                    }
                }
                let sortedParticipants = self.participants.sorted(by: { $0.value.name < $1.value.name })
                self.filteredParticipants = Dictionary(uniqueKeysWithValues: sortedParticipants)

                self.tableView.reloadData()
            }
    }


    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredParticipants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ParticipantTableViewCell else {
            return UITableViewCell()
        }

        let documentID = Array(filteredParticipants.keys)[indexPath.row]
        let participant = filteredParticipants[documentID]!
        let displayValue: Bool

        switch TicketTypeEnum(rawValue: currentURLIndex) {
        case .participantKit:
            displayValue = participant.participantKit
        case .entry:
            displayValue = participant.entry
        case .mainFood:
            displayValue = participant.mainFood
        case .snack:
            displayValue = participant.snack
        case .none:
            displayValue = false
        }

        cell.configure(id: documentID, name: participant.name, value: displayValue)

        let darkerGreen = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let darkerRed = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)

        cell.backgroundColor = displayValue ? darkerGreen : darkerRed

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // If search text is empty, show all participants in sorted order by name
            let sortedParticipantsArray = participants.sorted(by: { $0.value.name < $1.value.name })
            filteredParticipants = Dictionary(uniqueKeysWithValues: sortedParticipantsArray)
        } else {
            // If search text is not empty, filter participants based on search text and maintain sorted order by name
            let filteredParticipantsArray = participants.filter { (_, participant) in
                let matchesName = participant.name.lowercased().contains(searchText.lowercased())
                let matchesDocumentID = participant.documentID?.lowercased().contains(searchText.lowercased()) ?? false
                return matchesName || matchesDocumentID
            }
            let sortedFilteredParticipantsArray = filteredParticipantsArray.sorted(by: { $0.value.name < $1.value.name })
            // Convert the filtered array of tuples into a dictionary for display
            filteredParticipants = Dictionary(uniqueKeysWithValues: sortedFilteredParticipantsArray)
        }

        tableView.reloadData()
    }
}

