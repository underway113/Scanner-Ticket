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

    var title: String {
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

    var description: String {
        switch self {
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

    var backgroundColor: UIColor {
        switch self {
        case .participantKit:
            return UIColor(hex: "#1CB787")
        case .entry:
            return UIColor(hex: "#308FF5")
        case .mainFood:
            return UIColor(hex: "#F43E69")
        case .snack:
            return UIColor(hex: "#C969C9")
        }
    }
}
