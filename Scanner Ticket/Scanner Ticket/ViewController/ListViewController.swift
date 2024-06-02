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
    var emptyImageView = UIImageView()
    var emptyLabel = UILabel()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupSearchBar()
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
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
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
        emptyImageView.image = UIImage(named: "not-found")
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        view.addSubview(emptyImageView)

        NSLayoutConstraint.activate([
            emptyImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyImageView.heightAnchor.constraint(equalToConstant: 100),
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

    private func fetchParticipants() {
        showActivityIndicator()
        db.collection("Participants")
            .order(by: "name")
            .getDocuments { [weak self] (querySnapshot, error) in
                self?.hideActivityIndicator()
                guard let self = self else { return }
                if let error = error {
                    AlertManager.showErrorAlert(with: "Error fetching participants: \(error.localizedDescription)", completion: {})
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents")
                    return
                }

                self.participants = self.parseParticipants(documents)
                self.filteredParticipants = self.participants
                self.updateEmptyViewVisibility()
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

    private func updateEmptyViewVisibility() {
        let isEmpty = filteredParticipants.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
    }

    @objc private func addParticipant() {
        let alert = UIAlertController(title: "Add New Participant", message: "Enter name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self.checkIfNameExists(name) { exists in
                    if exists {
                        AlertManager.showErrorAlert(with: "A participant with this name already exists.", completion: {})
                    } else {
                        let documentID = self.db.collection("Participants").document().documentID
                        let detailVC = DetailViewController()
                        detailVC.documentID = documentID
                        detailVC.name = name
                        detailVC.isNewParticipant = true
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    private func checkIfNameExists(_ name: String, completion: @escaping (Bool) -> Void) {
        db.collection("Participants").whereField("name", isEqualTo: name).getDocuments { (querySnapshot, error) in
            if let error = error {
                AlertManager.showErrorAlert(with: "Error checking name: \(error.localizedDescription)", completion: {})
                completion(false)
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    private func showActivityIndicator() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }

    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }

    @objc private func refreshParticipants() {
        fetchParticipants()
        refreshControl.endRefreshing()
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

        let participant = getSortedFilteredParticipant(at: indexPath.row)
        let detailVC = DetailViewController()
        detailVC.documentID = participant.documentID
        detailVC.name = participant.name
        detailVC.participantKit = participant.participantKit
        detailVC.entry = participant.entry
        detailVC.mainFood = participant.mainFood
        detailVC.snack = participant.snack
        detailVC.isNewParticipant = false
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredParticipants = searchText.isEmpty ? participants : filterParticipants(by: searchText)
        updateEmptyViewVisibility()
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
