//
//  GuestListViewModel.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseMessaging

@Observable
class AppState {
    private let db = Firestore.firestore()
    private let messageing = Messaging.messaging()
    var guests: [Guest] = [Guest]()

    func fetchData() {
        db.collection("Guests").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error: No Documents.")
                return
            }

            self.guests = documents.compactMap { queryDocumentSnapshot -> Guest? in
                return try? queryDocumentSnapshot.data(as: Guest.self)
            }
        }
    }

    func addGuest(guest: Guest) {
        do {
            try db.collection("Guests").addDocument(from: guest)

            print("IN ADDING GUEST")

            // TODO: ADD Notifications
            Task {
                var tokens: [Token] = []
                print("IN ADD")
                let documents = try await db.collection("Tokens").getDocuments().documents
                print("Doc: \(documents)")
                tokens = documents.compactMap { queryDocumentSnapshot -> Token? in
                    return try? queryDocumentSnapshot.data(as: Token.self)
                }
//                tokens = tokens.filter { token in
//                    token.id != guest.uid
//                }
                print(tokens)

                for token in tokens {
                    sendPushNotification(to: token.fcm_token, title: "", body: "A new Guest has been added")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateGuest(guest: Guest, data: [String: Any]) async {
        if let id = guest.id {
            do {
                try await db.collection("Guests").document(id).updateData(data)
                print("Document successfully updated")
            } catch {
                print("Error updating document: \(error)")
            }
        }
    }

//    func sendPushNotification(to token: String, title: String, body: String) {
//        let urlString = "https://fcm.googleapis.com/fcm/send"
//        let serverKey = "AAAASODo0bQ:APA91bHhgLqrHpK-BEblbW1uLUuJgnuWDX6YFGM5YvcyvgbqFrSJt74EkrOnAMquUnOn3lMy-rEBOMs75e1CAMSV8U14DnRHSoVB1aeshQfHe88o8ciwKmQOIADLZ5Lx0lh9t7sEXug_"
//        let url = URL(string: urlString)!
//        let paramString: [String: Any] = ["to": token,
//            "notification": ["title": title, "body": body],
//            "data": ["user": "test_id"]
//        ]
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
//
//        print(request)
//    }

    func sendPushNotification(to fcm: String, title: String, body: String) {
        let serverKey = "AAAASODo0bQ:APA91bHhgLqrHpK-BEblbW1uLUuJgnuWDX6YFGM5YvcyvgbqFrSJt74EkrOnAMquUnOn3lMy-rEBOMs75e1CAMSV8U14DnRHSoVB1aeshQfHe88o8ciwKmQOIADLZ5Lx0lh9t7sEXug_"

        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Set the request headers
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Set the request body data
        let requestBody: [String: Any] = [
            "to": fcm,
            "notification": [
                "title": title,
                "body": body
            ]
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
            request.httpBody = jsonData

            // Send the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                }
            }.resume()
        }
    }
}

struct Token: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var fcm_token: String
    var timestamp: Date
}
