//
//  AuthenticatedViewModel.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AuthenticationServices
import CryptoKit

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

@Observable
class AuthenticationViewModel {
    var fcm: String {
        get {
            return UserDefaults.standard.string(forKey: "FCM") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "FCM")
        }
    }
    var email: String {
        get {
            return UserDefaults.standard.string(forKey: "EMAIL") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "EMAIL")
        }
    }
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
    var uid: String {
        get {
            return UserDefaults.standard.string(forKey: "UID") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "UID")
        }
    }
    var password = ""
    var confirmPassword = ""
    var flow: AuthenticationFlow = .login
    var isValid = false
    var authenticationState: AuthenticationState = .unauthenticated
    var errorMessage = ""
    var user: User?
    var displayName = ""
    private var currentNonce: String?
    private var db = Firestore.firestore()
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init(fcm: String) {
        self.fcm = fcm
        registerAuthStateHandler()
        if email != "", uid != "" {
            if let fcm = Messaging.messaging().fcmToken {
                let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { permission in
                    switch permission.authorizationStatus {
                    case .authorized:
                        print("User granted permission for notification")
                        // Send fmc to server
                        let data = [
                            "fcm_token": fcm,
                            "timestamp": Date.now
                        ]
                        self.addFmc(data: data)
                    case .denied:
                        print("User denied notification permission")
                    case .notDetermined:
                        print("Notification permission haven't been asked yet")
                    case .provisional:
                        // @available(iOS 12.0, *)
                        print("The application is authorized to post non-interruptive user notifications.")
                    case .ephemeral:
                        // @available(iOS 14.0, *)
                        print("The application is temporarily authorized to post notifications. Only available to app clips.")
                    @unknown default:
                        print("Unknow Status")
                    }
                })
            }
        }
    }

    func addFmc(data: [String: Any]) {
        let userRef = db.collection("Tokens").document(uid)
        userRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully")
            }
        }
    }

    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.displayName = user?.displayName ?? user?.email ?? ""
                let tempEmail = user?.email ?? ""
                if user == nil {
                    self.authenticationState = .unauthenticated
                } else {
                    self.authenticationState = .authenticated
                }
                if tempEmail == self.email, tempEmail != "", self.email != "" {
                    self.authenticationState = .authenticated
                } else {
                    self.authenticationState = .unauthenticated
                }
            }
        }
    }
}

// MARK: - Email and Password Authentication
extension AuthenticationViewModel {
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            let authResult = try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            self.user = authResult.user
            let userId = authResult.user.uid
            uid = userId
            print("UID: \(uid)")
            let document = try await db.collection("Users").document(userId).getDocument()
            if let data = document.data() {
                if let emailAddress = data["email"] as? String,
                    let givenName = data["firstName"] as? String,
                    let familyName = data["lastName"] as? String {
                    email = emailAddress
                    firstName = givenName
                    lastName = familyName
                }
            }
            authenticationState = .authenticated
            return true
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

    func signUpWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = authResult.user
            let userId = authResult.user.uid
            uid = userId
            do {
                try await db.collection("Users").document(userId).setData([
                    "email": email.lowercased(),
                    "firstName": firstName,
                    "lastName": lastName,
                    ])
            } catch {
                print(error.localizedDescription)
            }
            authenticationState = .authenticated
            return true
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.email = ""
            self.firstName = ""
            self.lastName = ""
            self.password = ""
            self.fcm = ""
            authenticationState = .unauthenticated
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount() async -> Bool {
        do {
            try await user?.delete()
            self.email = ""
            self.firstName = ""
            self.lastName = ""
            self.password = ""
            self.fcm = ""
            authenticationState = .unauthenticated
            return true
        }
        catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
