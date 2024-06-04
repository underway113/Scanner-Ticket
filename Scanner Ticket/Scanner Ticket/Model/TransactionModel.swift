//
//  TransactionModel.swift
//  Scanner Ticket
//
//  Created by Jeremy Adam on 04/06/24.
//

import Foundation
import FirebaseFirestoreInternal

struct Transaction {
    let transactionType: String
    let participantName: String
    let transactionDetails: [String: Any]
    let timestamp: Timestamp

    init(transactionType: String, participantName: String, transactionDetails: [String: Any]) {
        self.transactionType = transactionType
        self.participantName = participantName
        self.transactionDetails = transactionDetails
        self.timestamp = Timestamp(date: Date())
    }
    
    init(transactionType: String, participantName: String, transactionDetails: [String: Any], timestamp: Timestamp) {
        self.transactionType = transactionType
        self.participantName = participantName
        self.transactionDetails = transactionDetails
        self.timestamp = timestamp
    }

    func toDictionary() -> [String: Any] {
        return [
            "transactionType": transactionType,
            "participantName": participantName,
            "transactionDetails": transactionDetails,
            "timestamp": timestamp
        ]
    }
}

class TransactionUtil {
    static func parseToArray(_ documents: [QueryDocumentSnapshot]) -> [Transaction] {
        return Array(documents.compactMap { document in
            let data = document.data()
            return createTransaction(from: data, with: document.documentID)
        })
    }

    private static func createTransaction(from data: [String: Any], with documentID: String) -> Transaction? {
        guard let transactionType = data["transactionType"] as? String,
              let participantName = data["participantName"] as? String,
              let transactionDetails = data["transactionDetails"] as? [String: Any],
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        return Transaction(transactionType: transactionType, participantName: participantName, transactionDetails: transactionDetails, timestamp: timestamp)
    }
}
