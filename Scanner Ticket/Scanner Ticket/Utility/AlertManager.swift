//
//  AlertManager.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 02/06/24.
//

import Foundation
import UIKit
import AVFoundation
import SwiftEntryKit

class AlertManager {
    static func showSuccessPopup(
        message: String,
        completion: @escaping () -> Void
    ) {
        // Title Configuration
        let title = EKProperty.LabelContent(
            text: message,
            style: .init(
                font: UIFont.boldSystemFont(ofSize: 24),
                color: EKColor(.black),
                alignment: .center
            )
        )

        // Description Configuration
        let description = EKProperty.LabelContent(
            text: "Success Scanned",
            style: .init(
                font: UIFont.systemFont(ofSize: 16),
                color: EKColor(.black),
                alignment: .center
            )
        )

        // Image Configuration
        let image = EKProperty.ImageContent(
            image: UIImage.tintedCheckmarkCircleFillImage(color: .systemGreen),
            size: CGSize(width: 100, height: 100),
            contentMode: .scaleAspectFit
        )

        // Button Configuration
        let buttonFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let buttonColor = UIColor.white
        let buttonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(buttonColor))
        let buttonLabel = EKProperty.LabelContent(text: "OK", style: buttonLabelStyle)
        let buttonContent = EKProperty.ButtonContent(
            label: buttonLabel,
            backgroundColor: EKColor(.systemGreen),
            highlightedBackgroundColor: EKColor(.systemGreen.withAlphaComponent(0.8))
        ) {
            SwiftEntryKit.dismiss {
                completion()
            }
        }

        // Button Bar Content
        let buttonBarContent = EKProperty.ButtonBarContent(
            with: buttonContent,
            separatorColor: .clear,
            buttonHeight: 50,
            expandAnimatedly: true
        )

        // Alert Message Configuration
        let message = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )

        let alertMessage = EKAlertMessage(
            simpleMessage: message,
            buttonBarContent: buttonBarContent
        )

        let contentView = EKAlertMessageView(with: alertMessage)

        // Configure the attributes
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.entryBackground = .color(color: EKColor(.white))
        attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.5)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.roundCorners = .all(radius: 25)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 0.7, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 0.7, initialVelocity: 0)))
        attributes.positionConstraints.size = .init(width: .offset(value: 30), height: .intrinsic)
        attributes.statusBar = .dark

        AudioServicesPlaySystemSound(1520)
        // Display the entry
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }

    static func showErrorPopup(
        title: String,
        message: String,
        completion: @escaping () -> Void
    ) {
        // Title Configuration
        let title = EKProperty.LabelContent(
            text: title,
            style: .init(
                font: UIFont.boldSystemFont(ofSize: 24),
                color: EKColor(.black),
                alignment: .center
            )
        )

        // Description Configuration
        let description = EKProperty.LabelContent(
            text: message,
            style: .init(
                font: UIFont.systemFont(ofSize: 16),
                color: EKColor(.black),
                alignment: .center
            )
        )

        // Image Configuration
        let image = EKProperty.ImageContent(
            image: UIImage.tintedXCircleFillImage(color: .systemRed),
            size: CGSize(width: 100, height: 100),
            contentMode: .scaleAspectFit
        )

        // Button Configuration
        let buttonFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let buttonColor = UIColor.white
        let buttonLabelStyle = EKProperty.LabelStyle(font: buttonFont, color: EKColor(buttonColor))
        let buttonLabel = EKProperty.LabelContent(text: "OK", style: buttonLabelStyle)
        let buttonContent = EKProperty.ButtonContent(
            label: buttonLabel,
            backgroundColor: EKColor(.systemRed),
            highlightedBackgroundColor: EKColor(.systemRed.withAlphaComponent(0.8))
        ) {
            SwiftEntryKit.dismiss {
                completion()
            }
        }

        // Button Bar Content
        let buttonBarContent = EKProperty.ButtonBarContent(
            with: buttonContent,
            separatorColor: .clear,
            buttonHeight: 50,
            expandAnimatedly: true
        )

        // Alert Message Configuration
        let message = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )

        let alertMessage = EKAlertMessage(
            simpleMessage: message,
            buttonBarContent: buttonBarContent
        )

        let contentView = EKAlertMessageView(with: alertMessage)

        // Configure the attributes
        var attributes = EKAttributes()
        attributes.position = .center
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.entryBackground = .color(color: EKColor(.white))
        attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.5)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.roundCorners = .all(radius: 25)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 0.7, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 0.7, initialVelocity: 0)))
        attributes.positionConstraints.size = .init(width: .offset(value: 30), height: .intrinsic)
        attributes.statusBar = .dark

        AudioServicesPlaySystemSound(1521)
        // Display the entry
        SwiftEntryKit.display(entry: contentView, using: attributes)
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

