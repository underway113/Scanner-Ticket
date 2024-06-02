//
//  AlertManager.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 02/06/24.
//

import Foundation
import UIKit
import AVFoundation

class AlertManager {

    static func showSuccessAlert(with message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })

        AudioServicesPlaySystemSound(1520)
        UIViewController.topViewController()?.present(alertController, animated: true, completion: nil)
    }

    static func showErrorAlert(with message: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        AudioServicesPlaySystemSound(1521)
        UIViewController.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController {
    static func topViewController(controller: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first(where: { $0.activationState == .foregroundActive })?
        .windows
        .first(where: { $0.isKeyWindow })?
        .rootViewController) -> UIViewController? {
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
}

