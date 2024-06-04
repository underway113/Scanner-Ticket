//
//  ViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import UIKit
import AVFoundation
import FirebaseFirestore
import SwiftySound

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var currentURLIndex = 0
    let db = Firestore.firestore()
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .black
        return indicator
    }()

    let scanTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 45, weight: .semibold)
        return label
    }()

    let topLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "MODA FamDay 2024"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        return label
    }()

    let lastScanTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Last Scanned QR:"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        return label
    }()

    let lastScanLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let participantListButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("PARTICIPANTS", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        return button
    }()

    let transactionListButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("TRANSACTIONS", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        return button
    }()

    let exportParticipantButton: UIButton = {
        let button = UIButton(type: .system)
        let btnImage = UIImage(named: "export-csv")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(btnImage , for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()

    let exportTransactionButton: UIButton = {
        let button = UIButton(type: .system)
        let btnImage = UIImage(named: "export-csv")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(btnImage , for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = 10
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return button
    }()


    let versionLabel: UILabel = {
        let label = UILabel()
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "v\(version)"
        } else {
            print("Unable to fetch the app version.")
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10, weight: .thin)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        setupCaptureSession()
        setupBackgroundView()
        setupPreviewLayer()
        setupScanTypeLabel()
        setupTopLabel()
        setupLastScanLabel()
        setupParticipantListButton()
        setupExportParticipantButton()
        setupVersionLabel()
        setupTransactionsListButton()
        setupExportTransactionButton()
        updateView()
    }

    private func setupGestureRecognizers() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
    }

    private func setupCaptureSession() {
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
    }

    private func setupBackgroundView() {
        view.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        previewLayer.cornerRadius = 20
        previewLayer.masksToBounds = true
        previewLayer.position = bgView.center
        bgView.layer.addSublayer(previewLayer)

        let borderLayer = CALayer()
        borderLayer.frame = previewLayer.bounds
        borderLayer.cornerRadius = 20
        borderLayer.borderWidth = 2.0
        borderLayer.borderColor = UIColor.white.cgColor
        borderLayer.masksToBounds = true
        previewLayer.addSublayer(borderLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    private func setupScanTypeLabel() {
        bgView.addSubview(scanTypeLabel)
        NSLayoutConstraint.activate([
            scanTypeLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            scanTypeLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -200)
        ])
    }

    private func setupTopLabel() {
        bgView.addSubview(topLabel)
        NSLayoutConstraint.activate([
            topLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            topLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 220)
        ])
    }

    private func setupLastScanLabel() {
        bgView.addSubview(lastScanTitleLabel)
        bgView.addSubview(lastScanLabel)
        NSLayoutConstraint.activate([
            lastScanLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 20),
            lastScanLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -20),
            lastScanLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            lastScanLabel.topAnchor.constraint(equalTo: scanTypeLabel.bottomAnchor, constant: 50),
            lastScanTitleLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            lastScanTitleLabel.bottomAnchor.constraint(equalTo: lastScanLabel.topAnchor, constant: -6)
        ])
    }

    private func setupTransactionsListButton() {
        transactionListButton.addTarget(self, action: #selector(transactionsListButtonTapped), for: .touchUpInside)
        bgView.addSubview(transactionListButton)

        NSLayoutConstraint.activate([
            transactionListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            transactionListButton.heightAnchor.constraint(equalToConstant: 50),
            transactionListButton.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -10)
        ])
    }

    private func setupVersionLabel() {
        bgView.addSubview(versionLabel)
        NSLayoutConstraint.activate([
            versionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            versionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }

    private func setupParticipantListButton() {
        participantListButton.addTarget(self, action: #selector(participantListButtonTapped), for: .touchUpInside)
        view.addSubview(participantListButton)
        NSLayoutConstraint.activate([
            participantListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            participantListButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            participantListButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupExportParticipantButton() {
        exportParticipantButton.addTarget(self, action: #selector(exportParticipantButtonTapped), for: .touchUpInside)
        view.addSubview(exportParticipantButton)
        NSLayoutConstraint.activate([
            exportParticipantButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exportParticipantButton.trailingAnchor.constraint(equalTo: participantListButton.leadingAnchor, constant: -20),
            exportParticipantButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exportParticipantButton.widthAnchor.constraint(equalToConstant: 50),
            exportParticipantButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupExportTransactionButton() {
        exportTransactionButton.addTarget(self, action: #selector(exportTransactionButtonTapped), for: .touchUpInside)
        view.addSubview(exportTransactionButton)
        NSLayoutConstraint.activate([
            exportTransactionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exportTransactionButton.trailingAnchor.constraint(equalTo: transactionListButton.leadingAnchor, constant: -20),
            exportTransactionButton.bottomAnchor.constraint(equalTo: versionLabel.topAnchor, constant: -10),
            exportTransactionButton.widthAnchor.constraint(equalToConstant: 50),
            exportTransactionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.position = CGPoint(x: bgView.frame.midX, y: bgView.frame.midY)
    }

    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        AudioServicesPlaySystemSound(1520)
        if gesture.direction == .left {
            currentURLIndex = (currentURLIndex + 1) % URLs.redirect.count
        } else if gesture.direction == .right {
            currentURLIndex = (currentURLIndex - 1 + URLs.redirect.count) % URLs.redirect.count
        }

        self.updateView()
    }

    private func updateView() {
        guard let ticketType = TicketTypeEnum(rawValue: currentURLIndex) else {
            scanTypeLabel.text = "ERROR"
            scanTypeLabel.textColor = .white
            bgView.backgroundColor = .black
            return
        }

        scanTypeLabel.text = ticketType.title
        scanTypeLabel.textColor = .white
        bgView.backgroundColor = ticketType.backgroundColor
    }

    private func failed() {
        let alertController = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)

        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            found(code: stringValue)
        }
    }

    private func showLastScanLabel(code: String) {
        lastScanLabel.text = code
    }

    private func found(code: String) {
        showLastScanLabel(code: code)
        Task {
            showActivityIndicator()
            let components = parseCode(code)

            guard let documentID = components.documentID, let name = components.name else {
                AlertManager.showErrorAlert(with: "\(code)\nInvalid QR Code") {
                    self.viewWillAppear(true)
                }
                hideActivityIndicator()
                return
            }

            do {
                let participant = try await fetchParticipant(documentID: documentID, name: name)
                guard let participant = participant else {
                    AlertManager.showErrorAlert(with: "\(code)\nParticipant Not Found") {
                        self.viewWillAppear(true)
                    }
                    hideActivityIndicator()
                    return
                }

                if let fieldValue = getFieldStatus(participant: participant), fieldValue {
                    AlertManager.showErrorAlert(with: "\(code)\nQR already Scanned!") {
                        self.viewWillAppear(true)
                    }
                } else {
                    try await updateField(documentID: documentID, name: name)
                    playSuccessSound()
                    AlertManager.showSuccessAlert(with: "\(code)\nSuccess Scanned") {
                        self.viewWillAppear(true)
                    }
                }
            } catch {
                AlertManager.showErrorAlert(with: "Error: \(error.localizedDescription)") {
                    self.viewWillAppear(true)
                }
            }
            hideActivityIndicator()
        }
    }

    private func parseCode(_ code: String) -> (documentID: String?, name: String?) {
        let components = code.components(separatedBy: "_")
        guard components.count == 2 else {
            return (nil, nil)
        }
        return (components[0], components[1])
    }

    private func fetchParticipant(documentID: String, name: String) async throws -> [String: Any]? {
        let docRef = db.collection("Participants").document(documentID)
        let document = try await docRef.getDocument()
        guard document.exists, let data = document.data(), let participantName = data["name"] as? String, participantName == name else {
            return nil
        }
        return data
    }

    private func getFieldStatus(participant: [String: Any]) -> Bool? {
        guard let ticketType = TicketTypeEnum(rawValue: self.currentURLIndex) else {
            return nil
        }
        let fieldName = ticketType.description
        return participant[fieldName] as? Bool
    }

    private func updateField(documentID: String, name: String) async throws {
        guard let ticketType = TicketTypeEnum(rawValue: self.currentURLIndex) else {
            return
        }
        let fieldName = ticketType.description
        let docRef = db.collection("Participants").document(documentID)
        try await docRef.updateData([fieldName: true])
        addTransaction(
            transaction: Transaction(
                transactionType: "update",
                participantName: name,
                transactionDetails: [fieldName: true]
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

    private func entryFieldName(for index: Int) -> String {
        guard let ticketType = TicketTypeEnum(rawValue: index) else {
            return "entry"
        }
        switch ticketType {
        case .participantKit:
            return "participantKit"
        case .entry:
            return "entry"
        case .mainFood:
            return "mainFood"
        case .snack:
            return "snack"
        }
    }

    func playSuccessSound() {
        // Set the audio session category to allow playback even when silent
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting audio session category: \(error.localizedDescription)")
        }

        Sound.play(file: "scanner_sound.mp3")
    }

    @objc func participantListButtonTapped() {
        guard let navigationController = navigationController else {
            print("Navigation controller is nil.")
            return
        }

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }

        let listVC = ListViewController()
        listVC.currentURLIndex = self.currentURLIndex
        navigationController.pushViewController(listVC, animated: true)
    }

    @objc func transactionsListButtonTapped() {
        guard let navigationController = navigationController else {
            print("Navigation controller is nil.")
            return
        }

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }

        let transactionListVC = TransactionListViewController()
        navigationController.pushViewController(transactionListVC, animated: true)
    }

    @objc func exportParticipantButtonTapped() {
        showActivityIndicator()

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        Task {
            do {
                let participantsData = try await self.fetchAllParticipants()
                let csvString = convertToCSV(participantsData: participantsData)
                let csvURL = try saveCSVToFile(csvString: csvString)
                shareCSVFile(csvURL: csvURL)
            } catch {
                AlertManager.showErrorAlert(with: "Error: \(error.localizedDescription)") {
                    self.viewWillAppear(true)
                }
            }
            hideActivityIndicator()
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    @objc func exportTransactionButtonTapped() {
        showActivityIndicator()

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        Task {
            do {
                let transactionsData = try await self.fetchAllTransactions()
                let csvString = convertToCSV(transactionsData: transactionsData)
                let csvURL = try saveCSVToFile(csvString: csvString)
                shareCSVFile(csvURL: csvURL)
            } catch {
                AlertManager.showErrorAlert(with: "Error: \(error.localizedDescription)") {
                    self.viewWillAppear(true)
                }
            }
            hideActivityIndicator()
        }
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }

    private func fetchAllParticipants() async throws -> [Participant] {
        let querySnapshot = try await db.collection("Participants").order(by: "name").getDocuments()
        return ParticipantUtil.parseToArray(querySnapshot.documents)
    }

    private func fetchAllTransactions() async throws -> [Transaction] {
        let querySnapshot = try await db.collection("Transactions").order(by: "timestamp", descending: true).getDocuments()
        return TransactionUtil.parseToArray(querySnapshot.documents)
    }

    private func convertToCSV(participantsData: [Participant]) -> String {
        var csvString = "ID;Name;Participant Kit;Entry;Main Food;Snack\n"
        for data in participantsData {
            csvString.append("\(data.documentID);\(data.name);\(data.participantKit);\(data.entry);\(data.mainFood);\(data.snack)\n")
        }
        return csvString
    }

    private func convertToCSV(transactionsData: [Transaction]) -> String {
        var csvString = "Name,Date,Time,Type,ParticipantKit,Entry,Main Food,Snack\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        for data in transactionsData {
            let date = dateFormatter.string(from: data.timestamp.dateValue())
            let time = timeFormatter.string(from: data.timestamp.dateValue())

            let participantKit = data.transactionDetails["participantKit"] ?? ""
            let entry = data.transactionDetails["entry"] ?? ""
            let mainFood = data.transactionDetails["mainFood"] ?? ""
            let snack = data.transactionDetails["snack"] ?? ""

            csvString.append("\(data.participantName),\(date),\(time),\(data.transactionType),\(participantKit),\(entry),\(mainFood),\(snack)\n")
        }

        return csvString
    }


    private func saveCSVToFile(csvString: String) throws -> URL {
        let fileName = "participantsMODA.csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try csvString.write(to: path, atomically: true, encoding: .utf8)
        return path
    }

    private func shareCSVFile(csvURL: URL) {
        let activityViewController = UIActivityViewController(activityItems: [csvURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    private func showActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
