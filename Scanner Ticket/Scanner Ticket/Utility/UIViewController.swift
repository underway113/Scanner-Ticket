//
//  UIViewController.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 11/06/24.
//

import Foundation
import UIKit

extension UIViewController {
    func isTopViewController() -> Bool {
        return navigationController?.topViewController == self
    }
}
