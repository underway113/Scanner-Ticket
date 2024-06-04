//
//  DetailViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 02/06/24.
//

import FirebaseFirestore
import UIKit
import QRCode

class DetailViewController: UIViewController {
    var documentID: String = ""
    var name: String = ""
    var participantKit: Bool = false
    var entry: Bool = false
    var mainFood: Bool = false
    var snack: Bool = false

    var existParticipantKit: Bool = false
    var existEntry: Bool = false
    var existMainFood: Bool = false
    var existSnack: Bool = false
    
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
    private let qrImageView = UIImageView()
    private let saveButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureSaveButton()
        populateFields()
    }

    private func setupView() {
        view.backgroundColor = .black
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationItem.title = isNewParticipant ? "New Participant" : "Detail"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareQRCode))

        // Configure labels and toggles
        configureLabel(nameLabel, text: "name", fontSize: 30, bold: true, align: .center)
        configureLabel(documentIDLabel, text: documentID, fontSize: 18, bold: false, align: .center)
        configureLabel(participantKitLabel, text: "Participant Kit", fontSize: 18, bold: false)
        configureToggle(participantKitToggle, isOn: participantKit, action: #selector(toggleChanged))
        configureLabel(entryLabel, text: "Entry", fontSize: 18, bold: false)
        configureToggle(entryToggle, isOn: entry, action: #selector(toggleChanged))
        configureLabel(mainFoodLabel, text: "Main Food", fontSize: 18, bold: false)
        configureToggle(mainFoodToggle, isOn: mainFood, action: #selector(toggleChanged))
        configureLabel(snackLabel, text: "Snack", fontSize: 18, bold: false)
        configureToggle(snackToggle, isOn: snack, action: #selector(toggleChanged))
        configureImageView(qrImageView, image: "not-found")

        // Configure save button
        saveButton.setTitle("SAVE", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
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
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            documentIDLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            documentIDLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
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

            qrImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: 250),
            qrImageView.heightAnchor.constraint(equalToConstant: 250),
            qrImageView.topAnchor.constraint(equalTo: snackLabel.bottomAnchor, constant: 50),

            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureLabel(_ label: UILabel, text: String, fontSize: CGFloat, bold: Bool, align: NSTextAlignment = .left) {
        label.text = text
        label.textAlignment = align
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

    private func configureImageView(_ imageView: UIImageView, image: String) {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "not-found")
        view.addSubview(imageView)
    }

    private func configureSaveButton() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 8
        saveButton.tintColor = .white
        saveButton.addTarget(self, action: #selector(saveParticipant), for: .touchUpInside)
    }

    private func populateFields() {
        nameLabel.text = "\(name)"
        documentIDLabel.text = "\(documentID)"
        participantKitToggle.isOn = participantKit
        entryToggle.isOn = entry
        mainFoodToggle.isOn = mainFood
        snackToggle.isOn = snack

        let QRimage = generateQRCode(from: "\(documentID)_\(name)")
        qrImageView.image = QRimage
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

            let dataTransaction: [String: Any] = [
                "participantKit": participantKit,
                "entry": entry,
                "mainFood": mainFood,
                "snack": snack
            ]
            addTransaction(
                transaction: Transaction(
                    transactionType: "add",
                    participantName: name,
                    transactionDetails: dataTransaction
                )
            )
        }
        else {
            db.collection("Participants").document(documentID).updateData(data) { [weak self] error in
                self?.handleSaveResult(error: error)
            }

            var dataTransaction: [String: Any] = [:]
            if existParticipantKit != participantKit {
                dataTransaction["participantKit"] = participantKit
            }
            if existEntry != entry {
                dataTransaction["entry"] = entry
            }
            if existMainFood != mainFood {
                dataTransaction["mainFood"] = mainFood
            }
            if existSnack != snack {
                dataTransaction["snack"] = snack
            }
            addTransaction(
                transaction: Transaction(
                    transactionType: "update",
                    participantName: name,
                    transactionDetails: dataTransaction
                )
            )
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

    private func addTransaction(transaction: Transaction) {
        db.collection("Transactions").addDocument(data: transaction.toDictionary()) { err in
            if let err = err {
                print("Error adding transaction: \(err)")
            } else {
                print("Transaction successfully added!")
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        do {
            guard let imgLogo = UIImage(named: "ic-moda")?.cgImage else { return nil }
            let blueColor = UIColor(hex: "#354A9F").cgColor
            let redColor = UIColor(hex: "#D9232A").cgColor
            let imageData = try QRCode.build
                .logo(imgLogo, position: .squareCenter(inset: 2))
                .text(string, textEncoding: .utf8)
                .errorCorrection(.high)
                .quietZonePixelCount(1)
                .onPixels.style(blueColor)
                .onPixels.shape(QRCode.PixelShape.RoundedPath())
                .eye.style(blueColor)
                .eye.shape(QRCode.EyeShape.Squircle())
                .pupil.style(redColor)
                .generate
                .image(dimension: 600, representation: .png())

            return UIImage(data: imageData)
        } catch {
            print("Error generating QR code: \(error)")
            return nil
        }
    }

    @objc private func shareQRCode() {
        let img = qrImageView.image
        let name = nameLabel.text ?? ""
        let messageStr = """
            Halo \(name)!

            Kami dengan senang hati mengundang Anda untuk menghadiri *MODA Family Day 2024* yang akan diselenggarakan di 
                *Trans Studio Cibubur*
                *27 Juli 2024*
            Mari kita bersama-sama merayakan hari yang penuh kegembiraan, kebersamaan, dan kenangan indah.

            Silakan bawa QR Code berikut sebagai tiket masuk Anda. Kami tidak sabar untuk melihat Anda di sana dan berbagi momen istimewa bersama seluruh keluarga MODA!

            Sampai jumpa di acara!

            Salam hangat,
            Keluarga MODA
            """
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems:  [img!, messageStr], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.postToWeibo, .postToTwitter, .postToVimeo, .postToFlickr, . postToFacebook]
        self.present(activityViewController, animated: true, completion: nil)
    }
}

