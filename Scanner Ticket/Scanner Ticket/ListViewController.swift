import FirebaseFirestore
import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    public var currentURLIndex: Int = 0
    let db = Firestore.firestore()
    var participants: [String: Participant] = [:]
    var filteredParticipants: [String: Participant] = [:]
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBackgroundColorView()
        setupSearchBar()
        setupTableView()
        fetchParticipants()
    }

    private func setupView() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else {
            self.navigationItem.title = "ERROR"
            return
        }
        title = ticketType.description
        view.backgroundColor = ticketType.backgroundColor
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupBackgroundColorView() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else { return }

        let colorView = UIView()
        colorView.backgroundColor = ticketType.backgroundColor
        colorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(colorView)

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func fetchParticipants() {
        db.collection("Participants")
            .order(by: "name") // Order by name
            .getDocuments { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                self.participants = documents.reduce(into: [String: Participant]()) { (dict, document) in
                    let data = document.data()
                    if let name = data["name"] as? String,
                       let participantKit = data["participantKit"] as? Bool,
                       let entry = data["entry"] as? Bool,
                       let mainFood = data["mainFood"] as? Bool,
                       let snack = data["snack"] as? Bool {
                        let participant = Participant(name: name, participantKit: participantKit, entry: entry, mainFood: mainFood, snack: snack)
                        dict[document.documentID] = participant
                    }
                }
                self.filteredParticipants = self.participants
                self.tableView.reloadData()
            }
    }


    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredParticipants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

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
            displayValue = false // Default case
        }

        cell.textLabel?.text = "\(documentID) \(participant.name) \(displayValue)"
        cell.backgroundColor = displayValue ? .green : .red

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredParticipants = participants
        } else {
            filteredParticipants = participants.filter { key, participant in
                let documentID = key
                let displayValue: String
                switch TicketTypeEnum(rawValue: currentURLIndex) {
                case .participantKit:
                    displayValue = "\(participant.participantKit)"
                case .entry:
                    displayValue = "\(participant.entry)"
                case .mainFood:
                    displayValue = "\(participant.mainFood)"
                case .snack:
                    displayValue = "\(participant.snack)"
                case .none:
                    displayValue = "ERROR"
                }

                let cellText = "\(documentID) \(participant.name) \(displayValue)"
                return cellText.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}
