//
//  ParticipantModel.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import Foundation
import FirebaseFirestoreInternal

struct Participant: Hashable {
    let documentID: String
    let name: String
    let participantKit: Bool
    let entry: Bool
    let mainFood: Bool
    let snack: Bool

    static func == (lhs: Participant, rhs: Participant) -> Bool {
        return lhs.documentID == rhs.documentID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(documentID)
    }


}

class ParticipantUtil {

    static func parseToSetParticipants(_ documents: [QueryDocumentSnapshot]) -> Set<Participant> {
        return Set(documents.compactMap { document in
            let data = document.data()
            return createParticipant(from: data, with: document.documentID)
        })
    }

    static func parseToArrayParticipants(_ documents: [QueryDocumentSnapshot]) -> [Participant] {
        return Array(documents.compactMap { document in
            let data = document.data()
            return createParticipant(from: data, with: document.documentID)
        })
    }

    private static func createParticipant(from data: [String: Any], with documentID: String) -> Participant? {
        guard let name = data["name"] as? String,
              let participantKit = data["participantKit"] as? Bool,
              let entry = data["entry"] as? Bool,
              let mainFood = data["mainFood"] as? Bool,
              let snack = data["snack"] as? Bool else {
            return nil
        }
        return Participant(documentID: documentID, name: name, participantKit: participantKit, entry: entry, mainFood: mainFood, snack: snack)
    }
}
