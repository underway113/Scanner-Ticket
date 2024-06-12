//
//  UIImageExtension.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 06/06/24.
//

import Foundation
import UIKit

extension UIImage {
    static func tintedCheckmarkCircleFillImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "checkmark.circle.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedXCircleFillImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "x.circle.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedFilterImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        let tintedIcon = icon?.withRenderingMode(.alwaysOriginal)
        return tintedIcon!.withTintColor(color)
    }

    static func tintedCheckmarkSquareFillImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "checkmark.square.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedXSquareImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "x.square")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedNotFoundImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "person.fill.questionmark")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedQRCodeImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "qrcode.viewfinder")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedPlusAppImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "plus.app.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedPencilCircleImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "pencil.circle")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedHandDrawImage(color: UIColor = .white) -> UIImage {
        let icon = UIImage(systemName: "hand.draw")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }
}
