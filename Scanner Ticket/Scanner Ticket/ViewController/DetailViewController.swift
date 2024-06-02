//
//  DetailViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 02/06/24.
//

import FirebaseFirestore
import UIKit

class DetailViewController: UIViewController {
    var documentID: String = ""
    var name: String = ""
    var participantKit: Bool = false
    var entry: Bool = false
    var mainFood: Bool = false
    var snack: Bool = false
    var isNewParticipant: Bool = false

    let db = Firestore.firestore()

    private let nameLabel = UILabel()
    private let documentIDLabel = UILabel()
    private let participantKitLabel = UILabel()
    private let participantKitToggle = UISwitch()
    private let entryLabel = UILabel()
    private let entryToggle = UISwitch()
    private let mainFoodLabel = UILabel()
    private let mainFoodToggle = UISwitch()
    private let snackLabel = UILabel()
    private let snackToggle = UISwitch()
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureSaveButton()
        populateFields()
    }

    private func setupView() {
        view.backgroundColor = .black
        navigationItem.title = isNewParticipant ? "New Participant" : "Detail"

        // Configure labels and toggles
        configureLabel(nameLabel, text: "Name: \(name)", fontSize: 18, bold: true)
        configureLabel(documentIDLabel, text: "Document ID: \(documentID)", fontSize: 16, bold: false)
        configureLabel(participantKitLabel, text: "Participant Kit", fontSize: 16, bold: false)
        configureToggle(participantKitToggle, isOn: participantKit, action: #selector(toggleChanged))
        configureLabel(entryLabel, text: "Entry", fontSize: 16, bold: false)
        configureToggle(entryToggle, isOn: entry, action: #selector(toggleChanged))
        configureLabel(mainFoodLabel, text: "Main Food", fontSize: 16, bold: false)
        configureToggle(mainFoodToggle, isOn: mainFood, action: #selector(toggleChanged))
        configureLabel(snackLabel, text: "Snack", fontSize: 16, bold: false)
        configureToggle(snackToggle, isOn: snack, action: #selector(toggleChanged))

        // Configure save button
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 8
        saveButton.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveParticipant), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)

        // Layout constraints
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            documentIDLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            documentIDLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            documentIDLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            participantKitLabel.topAnchor.constraint(equalTo: documentIDLabel.bottomAnchor, constant: 30),
            participantKitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            participantKitToggle.centerYAnchor.constraint(equalTo: participantKitLabel.centerYAnchor),
            participantKitToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            entryLabel.topAnchor.constraint(equalTo: participantKitLabel.bottomAnchor, constant: 30),
            entryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            entryToggle.centerYAnchor.constraint(equalTo: entryLabel.centerYAnchor),
            entryToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            mainFoodLabel.topAnchor.constraint(equalTo: entryLabel.bottomAnchor, constant: 30),
            mainFoodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            mainFoodToggle.centerYAnchor.constraint(equalTo: mainFoodLabel.centerYAnchor),
            mainFoodToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            snackLabel.topAnchor.constraint(equalTo: mainFoodLabel.bottomAnchor, constant: 30),
            snackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            snackToggle.centerYAnchor.constraint(equalTo: snackLabel.centerYAnchor),
            snackToggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.topAnchor.constraint(equalTo: snackLabel.bottomAnchor, constant: 50),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, bold: Bool) {
        label.text = text
        label.textColor = .white
        label.font = bold ? UIFont.boldSystemFont(ofSize: fontSize) : UIFont.systemFont(ofSize: fontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }

    private func configureToggle(_ toggle: UISwitch, isOn: Bool, action: Selector) {
        toggle.isOn = isOn
        toggle.addTarget(self, action: action, for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggle)
    }

    private func configureSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 8
        saveButton.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveParticipant), for: .touchUpInside)
    }

    private func populateFields() {
        nameLabel.text = "Name: \(name)"
        documentIDLabel.text = "Document ID: \(documentID)"
        participantKitToggle.isOn = participantKit
        entryToggle.isOn = entry
        mainFoodToggle.isOn = mainFood
        snackToggle.isOn = snack
    }

    @objc private func toggleChanged(_ sender: UISwitch) {
        switch sender {
        case participantKitToggle:
            participantKit = sender.isOn
        case entryToggle:
            entry = sender.isOn
        case mainFoodToggle:
            mainFood = sender.isOn
        case snackToggle:
            snack = sender.isOn
        default:
            break
        }
    }

    @objc private func saveParticipant() {
        let data: [String: Any] = [
            "name": name,
            "participantKit": participantKit,
            "entry": entry,
            "mainFood": mainFood,
            "snack": snack
        ]

        if isNewParticipant {
            db.collection("Participants").document(documentID).setData(data) { [weak self] error in
                self?.handleSaveResult(error: error)
            }
        } else {
            db.collection("Participants").document(documentID).updateData(data) { [weak self] error in
                self?.handleSaveResult(error: error)
            }
        }
    }

    private func handleSaveResult(error: Error?) {
        if let error = error {
            showAlert(message: "Error saving participant: \(error.localizedDescription)")
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

