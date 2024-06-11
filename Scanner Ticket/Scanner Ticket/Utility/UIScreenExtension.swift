//
//  UIScreenExtension.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 11/06/24.
//

import Foundation
import UIKit

extension UIScreen {
    var minEdge: CGFloat {
        return min(self.bounds.width, self.bounds.height)
    }
}
