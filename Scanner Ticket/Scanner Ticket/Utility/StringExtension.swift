//
//  StringExtension.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 03/06/24.
//

import Foundation

extension String {
    static func randomDocumentID(length: Int) -> String {
        let characters = "ABCDEFGHJKLMPRSTWXYZ23456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }

    static func isInCharacterSelection(code: String) -> Bool {
        let characterset = CharacterSet(charactersIn: "ABCDEFGHJKLMPRSTWXYZ23456789")
        if code.rangeOfCharacter(from: characterset.inverted) != nil {
            print("string contains special characters")
            return false
        }
        return true
    }
}
