//
//  ViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import UIKit
import AVFoundation
//import FirebaseFirestore

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var currentURLIndex = 0

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

//    let db = Firestore.firestore()

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
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    let bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("List", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        //        createDocument()
        setupGestureRecognizers()
        setupCaptureSession()
        setupBackgroundView()
        setupPreviewLayer()
        setupScanTypeLabel()
        setupTopLabel()
        setupLastScanLabel()
        setuplistButton()
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
        previewLayer.frame = CGRect(x: 0, y: 0, width: 350, height: 350)
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
            lastScanLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            lastScanLabel.topAnchor.constraint(equalTo: scanTypeLabel.bottomAnchor, constant: 50),
            lastScanTitleLabel.centerXAnchor.constraint(equalTo: bgView.centerXAnchor),
            lastScanTitleLabel.bottomAnchor.constraint(equalTo: lastScanLabel.topAnchor, constant: -6)
        ])
    }

    private func setuplistButton() {
        listButton.addTarget(self, action: #selector(listButtonTapped), for: .touchUpInside)
        view.addSubview(listButton)
        NSLayoutConstraint.activate([
            listButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            listButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            listButton.widthAnchor.constraint(equalToConstant: 200),
            listButton.heightAnchor.constraint(equalToConstant: 50)
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

        scanTypeLabel.text = ticketType.description
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

        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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

    private func found(code: String) {
        let extractedString = extractString(from: code)
        lastScanLabel.text = extractedString

        let urlString = URLs.redirect[currentURLIndex] + extractedString

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] success in
                guard let self = self else { return }
                if success {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.captureSession.startRunning()
                    }

                }
            })
        }
        else {
            showErrorAlert(with: extractedString, completion: {
                self.viewWillAppear(true)
            })
        }
    }

    private func extractString(from urlString: String) -> String {
        let components = urlString.components(separatedBy: "_")
        if components.count >= 2 {
            return urlString
        } else {
            return "\(urlString)\nInvalid QR Code!"
        }
    }

    private func showErrorAlert(with message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Extracted QR Code", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        AudioServicesPlaySystemSound(1521)
        present(alertController, animated: true, completion: nil)
    }

    @objc func listButtonTapped() {
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

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
