//
//  TicketTypeEnum.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import Foundation
import UIKit

enum TicketTypeEnum: Int {
    case participantKit = 0
    case entry = 1
    case mainFood = 2
    case snack = 3

    var description: String {
        switch self {
        case .participantKit:
            return "PARTICIPANT KIT"
        case .entry:
            return "ENTRY"
        case .mainFood:
            return "MAIN FOOD"
        case .snack:
            return "SNACK"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .participantKit:
            return UIColor(red: 0.11, green: 0.72, blue: 0.53, alpha: 1.0) // Green
        case .entry:
            return UIColor(red: 0.19, green: 0.56, blue: 0.96, alpha: 1.0) // Blue
        case .mainFood:
            return UIColor(red: 0.90, green: 0.30, blue: 0.26, alpha: 1.0) // Red
        case .snack:
            return UIColor(red: 0.61, green: 0.35, blue: 0.71, alpha: 1.0) // Purple
        }
    }
}
