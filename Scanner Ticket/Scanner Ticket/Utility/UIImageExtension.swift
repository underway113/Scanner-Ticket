//
//  UIImageExtension.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 06/06/24.
//

import Foundation
import UIKit

extension UIImage {
    static func tintedCheckmarkCircleFillImage(color: UIColor) -> UIImage {
        let icon = UIImage(systemName: "checkmark.circle.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedXCircleFillImage(color: UIColor) -> UIImage {
        let icon = UIImage(systemName: "x.circle.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(color)
    }

    static func tintedFilterImage(color: UIColor) -> UIImage {
        let icon = UIImage(systemName: "line.3.horizontal.decrease.circle.fill")
        let tintedIcon = icon?.withRenderingMode(.alwaysOriginal)
        return tintedIcon!.withTintColor(.white)
    }

    static func tintedCheckmarkSquareFillImage(color: UIColor) -> UIImage {
        let icon = UIImage(systemName: "checkmark.square.fill")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(.white)
    }

    static func tintedXSquareImage(color: UIColor) -> UIImage {
        let icon = UIImage(systemName: "x.square")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(.white)
    }

    static func tintedNotFoundImage(color: UIColor) -> UIImage {
        let icon = UIImage(systemName: "person.fill.questionmark")
        let tintedImage = icon?.withRenderingMode(.alwaysOriginal)
        return tintedImage!.withTintColor(.white)
    }



}
