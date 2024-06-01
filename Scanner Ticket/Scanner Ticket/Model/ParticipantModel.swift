//
//  ParticipantModel.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 31/05/24.
//

import Foundation

struct Participant: Codable {
    let name: String
    let participantKit: Bool
    let entry: Bool
    let mainFood: Bool
    let snack: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case participantKit
        case entry
        case mainFood
        case snack
    }
}


//    func addParticipantsFromCSVData() {
//        let csvData = """
//        0XP3WQ,Tester1
//        Z7VUMC,Tester2
//        VAJTGS,Tester3
//        JL3VTP,Tester4
//        20FVCG,Tester5
//        """
//
//        // Split CSV data into lines
//        let lines = csvData.components(separatedBy: "\n")
//
//        for line in lines {
//            // Split each line into fields
//            let fields = line.components(separatedBy: ",")
//
//            // Check if there are exactly two fields (documentID and name)
//            if fields.count == 2 {
//                let documentID = fields[0]
//                let name = fields[1]
//
//                // Create a Participant instance
//                let participant = Participant(name: name, participantKit: false, entry: false, mainFood: false, snack: false)
//
//                // Add participant to Firestore
//                addParticipant(participant: participant, documentID: documentID)
//            }
//        }
//    }


//func addParticipant(participant: Participant, documentID: String) {
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
