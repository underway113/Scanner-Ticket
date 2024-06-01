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
    var participants: Set<Participant> = []
    var filteredParticipants: Set<Participant> = []

    var tableView = UITableView()
    var searchBar = UISearchBar()
    var emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchBar()
        setupTableView()
        setupEmptyLabel()
        fetchParticipants()
    }

    private func setupView() {
        configureNavigationBar()
        configureViewBackground()
    }

    private func configureNavigationBar() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else {
            self.navigationItem.title = "ERROR"
            return
        }
        title = ticketType.title
        navigationController?.navigationBar.tintColor = .white
    }

    private func configureViewBackground() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else { return }
        view.backgroundColor = ticketType.backgroundColor
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

    private func setupEmptyLabel() {
        emptyLabel.text = "Data Not Found"
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        emptyLabel.isHidden = true // Initially hidden
    }

    private func fetchParticipants() {
        db.collection("Participants")
            .order(by: "name")
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    self.showAlert(message: "Error fetching participants: \(error.localizedDescription)")
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents")
                    return
                }

                self.participants = self.parseParticipants(documents)
                self.filteredParticipants = self.participants
                self.updateEmptyLabelVisibility()
                self.tableView.reloadData()
            }
    }

    private func parseParticipants(_ documents: [QueryDocumentSnapshot]) -> Set<Participant> {
        return Set(documents.compactMap { document in
            let data = document.data()
            return createParticipant(from: data, with: document.documentID)
        })
    }

    private func createParticipant(from data: [String: Any], with documentID: String) -> Participant? {
        guard let name = data["name"] as? String,
              let participantKit = data["participantKit"] as? Bool,
              let entry = data["entry"] as? Bool,
              let mainFood = data["mainFood"] as? Bool,
              let snack = data["snack"] as? Bool else {
            return nil
        }
        return Participant(documentID: documentID, name: name, participantKit: participantKit, entry: entry, mainFood: mainFood, snack: snack)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func updateEmptyLabelVisibility() {
        emptyLabel.isHidden = !filteredParticipants.isEmpty
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

        let participant = getSortedFilteredParticipant(at: indexPath.row)
        let displayValue = getDisplayValue(for: participant)

        cell.configure(id: participant.documentID, name: participant.name, value: displayValue)
        cell.backgroundColor = getBackgroundColor(for: displayValue)

        return cell
    }

    private func getSortedFilteredParticipant(at index: Int) -> Participant {
        return Array(filteredParticipants).sorted(by: { $0.name < $1.name })[index]
    }

    private func getDisplayValue(for participant: Participant) -> Bool {
        switch TicketTypeEnum(rawValue: currentURLIndex) {
        case .participantKit:
            return participant.participantKit
        case .entry:
            return participant.entry
        case .mainFood:
            return participant.mainFood
        case .snack:
            return participant.snack
        case .none:
            return false
        }
    }

    private func getBackgroundColor(for displayValue: Bool) -> UIColor {
        let darkerGreen = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let darkerRed = UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
        return displayValue ? darkerGreen : darkerRed
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredParticipants = searchText.isEmpty ? participants : filterParticipants(by: searchText)
        updateEmptyLabelVisibility()
        tableView.reloadData()
    }

    private func filterParticipants(by searchText: String) -> Set<Participant> {
        return participants.filter { participant in
            let matchesName = participant.name.lowercased().contains(searchText.lowercased())
            let matchesDocumentID = participant.documentID.lowercased().contains(searchText.lowercased())
            return matchesName || matchesDocumentID
        }
    }
}
