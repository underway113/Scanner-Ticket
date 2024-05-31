//
//  ViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var currentURLIndex = 0
    var urlsRedirect = [
        "https://docs.google.com/forms/d/e/1FAIpQLSfPjJ0pRhjU3Ic06quhlYuwPVZcHre4yXH_A6mjBBEK4OPQ6w/formResponse?entry.2008314890=",
        "https://example.com/url1",
        "https://example.com/url2",
        "https://example.com/url3"
    ]

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    let scanEntryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ENTRY"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 46, weight: .semibold)
        return label
    }()

    let bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 53/255, green: 74/255, blue: 159/255, alpha: 1.0)
        return view
    }()

    let topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 53/255, green: 74/255, blue: 159/255, alpha: 1.0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add swipe gesture recognizers
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)


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

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Add bottomView to the view
        view.addSubview(bottomView)
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 120),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.heightAnchor.constraint(equalToConstant: 120),
            topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topView.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        // Add scanEntryLabel to the bottomView
        bottomView.addSubview(scanEntryLabel)
        NSLayoutConstraint.activate([
            scanEntryLabel.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor),
            scanEntryLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20)
        ])
    }

    @objc func handleSwipe(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            // Swipe left
            currentURLIndex = (currentURLIndex + 1) % urlsRedirect.count
        } else if gesture.direction == .right {
            // Swipe right
            currentURLIndex = (currentURLIndex - 1 + urlsRedirect.count) % urlsRedirect.count
        }

        self.updateView()
    }

    private func updateView() {
        switch currentURLIndex {
        case 0:
            scanEntryLabel.text = "ENTRY"
            scanEntryLabel.textColor = UIColor.white
            bottomView.backgroundColor = UIColor.blue
            topView.backgroundColor = UIColor.blue
        case 1:
            scanEntryLabel.text = "PARTICIPANT KIT"
            scanEntryLabel.textColor = UIColor.white
            bottomView.backgroundColor = UIColor.green
            topView.backgroundColor = UIColor.green
        case 2:
            scanEntryLabel.text = "MAIN FOOD"
            scanEntryLabel.textColor = UIColor.white
            bottomView.backgroundColor = UIColor.red
            topView.backgroundColor = UIColor.red
        case 3:
            scanEntryLabel.text = "SNACK"
            scanEntryLabel.textColor = UIColor.white
            bottomView.backgroundColor = UIColor.purple
            topView.backgroundColor = UIColor.purple
        default:
            scanEntryLabel.text = "ERROR"
            scanEntryLabel.textColor = UIColor.white
            bottomView.backgroundColor = UIColor.black
            topView.backgroundColor = UIColor.black

        }
    }

    func failed() {
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
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }

    func found(code: String) {
        let extractedString = extractString(from: code)

        let urlString = urlsRedirect[currentURLIndex] + extractedString
        print("xoxo \(urlString)")

        //        let urlString = "https://docs.google.com/forms/d/e/1FAIpQLSfPjJ0pRhjU3Ic06quhlYuwPVZcHre4yXH_A6mjBBEK4OPQ6w/formResponse?entry.2008314890=\(extractedString)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] success in
                if success {
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Perform AVCaptureSession operations on a background thread
                        self?.captureSession.startRunning()
                    }

                }
            })
        }
        else {
            showAlert(with: extractedString, completion: {
                self.viewWillAppear(true)
            })
        }
    }

    func extractString(from urlString: String) -> String {
        let components = urlString.components(separatedBy: "_")
        if components.count >= 2 {
            return components[0]
        } else {
            return "\(urlString)\nInvalid QR Code!"
        }
    }

    func showAlert(with message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Extracted QR Code", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alertController, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
