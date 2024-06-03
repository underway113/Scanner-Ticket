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


//func addParticipantsFromCSVData() {
//    let csvData = """
//    0XP3WQ,Tester1
//    Z7VUMC,Tester2
//    VAJTGS,Tester3
//    JL3VTP,Tester4
//    20FVCG,Tester5
//    """
//
//    // Split CSV data into lines
//    let lines = csvData.components(separatedBy: "\n")
//
//    for line in lines {
//        // Split each line into fields
//        let fields = line.components(separatedBy: ",")
//
//        // Check if there are exactly two fields (documentID and name)
//        if fields.count == 2 {
//            let documentID = fields[0]
//            let name = fields[1]
//
//            // Create a Participant instance with documentID
//            var participant = Participant(name: name, participantKit: false, entry: false, mainFood: false, snack: false)
//            participant.documentID = documentID
//
//            // Add participant to Firestore
//            addParticipant(participant: participant)
//        }
//    }
//}
//
//func addParticipant(participant: Participant) {
//    guard let documentID = participant.documentID else {
//        print("Error: Participant's documentID is nil.")
//        return
//    }
//
//    let participantRef = db.collection("Participants").document(documentID)
//
//    participantRef.setData([
//        "name": participant.name,
//        "participantKit": participant.participantKit,
//        "entry": participant.entry,
//        "mainFood": participant.mainFood,
//        "snack": participant.snack
//    ]) { error in
//        if let error = error {
//            print("Error adding participant: \(error)")
//        } else {
//            print("Participant added successfully!")
//        }
//    }
//}
