//
//  GuestListViewModel.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import Foundation

@Observable
class AppState {
    var firstName: String {
        get {
            return UserDefaults.standard.string(forKey: "FIRST_NAME") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FIRST_NAME")
        }
    }

    var lastName: String {
        get {
            return UserDefaults.standard.string(forKey: "LAST_NAME") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LAST_NAME")
        }
    }

    private let db = Firestore.firestore()
    private let messageing = Messaging.messaging()
    var guests: [Guest] = [Guest]()

    func fetchData() {
        db.collection("Guests").addSnapshotListener { querySnapshot, _ in
            guard let documents = querySnapshot?.documents else {
                print("Error: No Documents.")
                return
            }

            self.guests = documents.compactMap { queryDocumentSnapshot -> Guest? in
                try? queryDocumentSnapshot.data(as: Guest.self)
            }
        }
    }

    func addGuest(guest: Guest) async {
        do {
            try db.collection("Guests").addDocument(from: guest)
            // TODO: ADD Notifications
            
            var tokens: [Token] = []
            let documents = try await db.collection("Tokens").getDocuments().documents
            tokens = documents.compactMap { queryDocumentSnapshot -> Token? in
                try? queryDocumentSnapshot.data(as: Token.self)
            }
            tokens = tokens.filter { token in
                token.id != guest.uid
            }
            for token in tokens {
                sendPushNotification(to: token.fcm_token, title: "", body: "\(getName(firstName: firstName, lastName: lastName)) added a new Guest")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func getNameFromUID(uid: String) async -> String {
        do {
            let document = try await db.collection("Users").document(uid).getDocument()
            let data = document.data()
            let firstName = data?["firstName"] as? String ?? ""
            let lastName = data?["lastName"] as? String ?? ""
            return getName(firstName: firstName, lastName: lastName)
        } catch {
            print(error.localizedDescription)
            return "Anonymous"
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

    func updateGuest(guest: Guest) async {
        if let id = guest.id {
            do {
                try await db.collection("Guests").document(id).updateData([
                    "uid": guest.uid,
                    "name": guest.name,
                    "guestCount": guest.guestCount,
                    "tableSelection": guest.tableSelection,
                    "isVip": guest.isVip,
                    "isFreeEntry": guest.isFreeEntry,
                    "isDiscount": guest.isDiscount,
//                    "isArchived": guest.isArchived,
                    "additionalInfo": guest.additionalInfo,
                ])
                print("Document successfully updated")
            } catch {
                print("Error updating document: \(error)")
            }
        }
    }

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
                "body": body,
            ],
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
            request.httpBody = jsonData

            // Send the request
            URLSession.shared.dataTask(with: request) { data, _, error in
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

func getName(firstName: String, lastName: String) -> String {
    if !firstName.isEmpty {
        return "\(firstName) \(lastName.first?.description.uppercased() ?? "")"
    } else {
        return "Anonymous"
    }
}
