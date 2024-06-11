//
//  ListViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import FirebaseFirestore
import UIKit
import AVFoundation

class ListViewController: UIViewController {

    public var currentURLIndex: Int = 0
    let db = Firestore.firestore()
    var participants: Set<Participant> = []
    var filteredParticipants: Set<Participant> = []

    var tableView = UITableView()
    var searchBar = UISearchBar()
    var infoView = UIView()
    var totalParticipantsLabel = UILabel()
    var statusLabel = UILabel()
    var emptyImageView = UIImageView()
    var emptyLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var refreshControl = UIRefreshControl()
    var filterButton = UIButton(type: .system)
    var filterMode: FilterMode = .all

    enum FilterMode {
        case all, trueOnly, falseOnly
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupSearchBar()
        setupFilterButton()
        setupInfoView()
        setupTableView()
        setupEmptyView()
        setupActivityIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        fetchParticipants()
    }

    private func configureNavigationBar() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else {
            self.navigationItem.title = "ERROR"
            return
        }
        title = ticketType.title
        navigationController?.navigationBar.backgroundColor = ticketType.backgroundColor
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addParticipant))
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }

    private func setupInfoView() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.backgroundColor = .black
        view.addSubview(infoView)

        totalParticipantsLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        infoView.addSubview(totalParticipantsLabel)
        infoView.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoView.heightAnchor.constraint(equalToConstant: 50),

            totalParticipantsLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            totalParticipantsLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor),

            statusLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.keyboardDismissMode = .interactive
        refreshControl.addTarget(self, action: #selector(refreshParticipants), for: .valueChanged)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: infoView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(ParticipantTableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func setupEmptyView() {
        emptyLabel.text = "Data Not Found"
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.image = UIImage.tintedNotFoundImage(color: .white)
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        view.addSubview(emptyImageView)

        NSLayoutConstraint.activate([
            emptyImageView.heightAnchor.constraint(equalToConstant: 86),
            emptyImageView.widthAnchor.constraint(equalToConstant: 100), //86
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 10),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        emptyLabel.isHidden = true
        emptyImageView.isHidden = true
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupFilterButton() {
        filterButton.tintColor = .white
        filterButton.setImage(UIImage.tintedFilterImage(color: .white) , for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)

        NSLayoutConstraint.activate([
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 8),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            filterButton.widthAnchor.constraint(equalToConstant: 24),
            filterButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    private func fetchParticipants() {
        showActivityIndicator()
        db.collection("Participants")
            .order(by: "name")
            .getDocuments { [weak self] (querySnapshot, error) in
                self?.hideActivityIndicator()
                guard let self = self else { return }
                if let error = error {
                    AlertManager.showErrorPopup(title: error.localizedDescription, message: "Error Fetching Participants", completion: {})
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents")
                    return
                }

                self.participants = ParticipantUtil.parseToSet(documents)
                self.applyFilter()
                self.updateEmptyViewVisibility()
                self.updateInfoLabels()
                self.tableView.reloadData()
            }
    }

    private func updateEmptyViewVisibility() {
        let isEmpty = filteredParticipants.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
    }

    private func updateInfoLabels() {
        let totalParticipants = participants.count
        var trueCount = 0
        var falseCount = 0

        for participant in participants {
            let value = getDisplayValue(for: participant)
            if value {
                trueCount += 1
            } else {
                falseCount += 1
            }
        }

        totalParticipantsLabel.text = "Total: \(totalParticipants)"
        statusLabel.text = "\(trueCount) scanned / \(falseCount) not scanned"
    }

    @objc private func addParticipant() {
        let alert = UIAlertController(title: "Add New Participant", message: "Enter name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .allCharacters
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            showActivityIndicator()
            Task {
                if let name = alert.textFields?.first?.text, !name.isEmpty {
                    do {
                        let exists = try await self.checkIfNameExists(name)
                        if exists {
                            self.hideActivityIndicator()
                            AlertManager.showErrorPopup(title: "A participant with this name already exists.", message: "", completion: {})
                        }
                        else {
                            var newDocumentID: String
                            var isUnique: Bool
                            repeat {
                                newDocumentID = String.randomDocumentID(length: 5)
                                isUnique = try await self.checkDocumentIDExists(documentID: newDocumentID)
                            } while !isUnique

                            let detailVC = DetailViewController()
                            detailVC.documentID = newDocumentID
                            detailVC.name = name
                            detailVC.isNewParticipant = true
                            self.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    }
                    catch {
                        self.hideActivityIndicator()
                        AlertManager.showErrorPopup(title: error.localizedDescription, message: "Error Checking Name", completion: {})
                    }
                }
            }
        }))
        hideActivityIndicator()
        present(alert, animated: true, completion: nil)
    }

    private func checkDocumentIDExists(documentID: String) async throws -> Bool {
        let docRef = db.collection("Participants").document(documentID)
        let document = try await docRef.getDocument()
        return !document.exists
    }

    private func checkIfNameExists(_ name: String) async throws -> Bool {
        let querySnapshot = try await db.collection("Participants").whereField("name", isEqualTo: name).getDocuments()
        return !querySnapshot.documents.isEmpty
    }

    private func showActivityIndicator() {
        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }

    @objc private func refreshParticipants() {
        fetchParticipants()
        refreshControl.endRefreshing()
    }

    @objc private func filterButtonTapped() {
        switch filterMode {
        case .all:
            filterMode = .trueOnly
        case .trueOnly:
            filterMode = .falseOnly
        case .falseOnly:
            filterMode = .all
        }
        applyFilter()
        tableView.reloadData()
    }

    private func applyFilter() {
        switch filterMode {
        case .all:
            filterButton.setImage(UIImage.tintedFilterImage(color: .white) , for: .normal)
            filteredParticipants = participants
        case .trueOnly:
            filterButton.setImage(UIImage.tintedCheckmarkSquareFillImage(color: .white), for: .normal)
            filteredParticipants = participants.filter { getDisplayValue(for: $0) }
        case .falseOnly:
            filterButton.setImage(UIImage.tintedXSquareImage(color: .white) , for: .normal)
            filteredParticipants = participants.filter { !getDisplayValue(for: $0) }
        }
        updateEmptyViewVisibility()
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
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
        let darkerGreen = UIColor(hex: "#12562A")
        let darkerRed = UIColor(hex: "#720714")
        return displayValue ? darkerGreen : darkerRed
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let participant = getSortedFilteredParticipant(at: indexPath.row)
        let detailVC = DetailViewController()
        detailVC.documentID = participant.documentID
        detailVC.name = participant.name
        detailVC.participantKit = participant.participantKit
        detailVC.entry = participant.entry
        detailVC.mainFood = participant.mainFood
        detailVC.snack = participant.snack
        detailVC.existParticipantKit = detailVC.participantKit
        detailVC.existEntry = detailVC.entry
        detailVC.existMainFood = detailVC.mainFood
        detailVC.existSnack = detailVC.snack
        detailVC.isNewParticipant = false
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Swipe right to do Scan function
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let participant = self.getSortedFilteredParticipant(at: indexPath.row)
        guard getDisplayValue(for: participant) == false else { return nil }
        let scanAction = UIContextualAction(style: .destructive, title: "Scan") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            Task {
                do {
                    try await self.updateField(documentID: participant.documentID, name: participant.name, value: true)
                    AudioServicesPlaySystemSound(1520)
                    self.fetchParticipants()
                    completionHandler(true)
                } catch {
                    AudioServicesPlaySystemSound(1521)
                    print("Error updating field: \(error)")
                    completionHandler(false)
                }
            }
        }
        scanAction.backgroundColor = .systemBlue

        let configuration = UISwipeActionsConfiguration(actions: [scanAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    // Swipe left to do Unscan function
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let participant = self.getSortedFilteredParticipant(at: indexPath.row)
        guard getDisplayValue(for: participant) == true else { return nil }
        let unscanAction = UIContextualAction(style: .destructive, title: "Unscan") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            Task {
                do {
                    try await self.updateField(documentID: participant.documentID, name: participant.name, value: false)
                    AudioServicesPlaySystemSound(1520)
                    self.fetchParticipants()
                    completionHandler(true)

                } catch {
                    AudioServicesPlaySystemSound(1521)
                    print("Error updating field: \(error)")
                    completionHandler(false)
                }
            }
        }
        unscanAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [unscanAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private func updateField(documentID: String, name: String, value: Bool) async throws {
        guard let ticketType = TicketTypeEnum(rawValue: self.currentURLIndex) else {
            return
        }
        let fieldName = ticketType.description
        let docRef = db.collection("Participants").document(documentID)
        try await docRef.updateData([fieldName: value])
        addTransaction(
            transaction: Transaction(
                transactionType: "swipe",
                participantName: name,
                transactionDetails: [fieldName: value]
            )
        )
    }

    private func addTransaction(transaction: Transaction) {
        db.collection("Transactions").addDocument(data: transaction.toDictionary()) { err in
            if let err = err {
                print("Error adding transaction: \(err)")
            } else {
                print("Transaction successfully added!")
            }
        }
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredParticipants = searchText.isEmpty ? participants : filterParticipants(by: searchText)
        filterButton.setTitle("ALL", for: .normal)
        updateEmptyViewVisibility()
        updateInfoLabels()
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
