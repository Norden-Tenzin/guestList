//
//  LoginView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI
import CloudKit
import AuthenticationServices
import FirebaseFirestore

enum loginState {
    case login
    case register
}

struct LoginView: View {
    @Environment(AuthenticationViewModel.self) var viewModel
    private var db = Firestore.firestore()
    @State var isActive: Bool = false
    @State var email: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var password: String = ""
    @State var loginState: loginState = .login
    @State var isButtonLoading: Bool = false

    @State var errorString: String = ""
    @State var showError: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                VStack {
                    Image("haferl_logo")
                        .frame(width: 200, height: 200)
                        .padding(.top, 50)
                    Spacer()
                }
                
                VStack(alignment: .center) {
                    Spacer()
                    if showError {
                        Text(errorString)
                            .foregroundStyle(Color.white)
                            .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showError = false
                                }
                            }
                        }
                    }
                    TextField("Email Address", text: $email)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .padding()
                        .background() {
                        Color(.secondarySystemBackground)
                    }
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    if loginState == .register {
                        HStack {
                            TextField("First Name", text: $firstName)
                                .autocorrectionDisabled()
                                .padding()
                                .background() {
                                Color(.secondarySystemBackground)
                            }
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            TextField("Last Name", text: $lastName)
                                .autocorrectionDisabled()
                                .padding()
                                .background() {
                                Color(.secondarySystemBackground)
                            }
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    }
                    SecureField("Password", text: $password)
                        .autocorrectionDisabled()
                        .padding()
                        .background() {
                        Color(.secondarySystemBackground)
                    }
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Button {
                        if loginState == .login {
                            if email.isEmpty {
                                errorString = "Please enter your email to proceed."
                                showError = true
                            } else if !isValidEmail(email) {
                                errorString = "Please enter a valid email to proceed."
                                showError = true
                            } else {
                                viewModel.email = email
                                viewModel.password = password
                                Task {
                                    await viewModel.signInWithEmailPassword()
                                }
                            }
                        } else {
                            if email.isEmpty {
                                errorString = "Please enter your email to proceed."
                                showError = true
                            } else if !isValidEmail(email) {
                                errorString = "Please enter a valid email to proceed."
                                showError = true
                            } else if password.count < 6 {
                                errorString = "Password must be 6 characters long or more."
                                showError = true
                            }
                            else {
                                //                            Register
                                viewModel.email = email
                                viewModel.firstName = firstName
                                viewModel.lastName = lastName
                                viewModel.password = password
                                Task {
                                    await viewModel.signUpWithEmailPassword()
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color(.accent))
                                .frame(height: 50)
                            Text(loginState == .login ? "LOGIN" : "SIGN UP")
                                .foregroundStyle(Color.white)
                                .fontWeight(.medium)
                        }
                    }
                        .buttonStyle(.plain)
                        .padding(.bottom, 10)
                    Button(action: {
                        if loginState == .login {
                            loginState = .register
                        } else {
                            loginState = .login
                        }
                    }, label: {
                            Text(loginState == .login ? "No Account? Signup here!" : "Have an Account? Login here!")
                                .fontWeight(.medium)
                        })
                        .tint(Color.white)
                }
                    .padding(.horizontal, 15)
                    .tint(Color(.accent))
            }
        }
            .onAppear() {
            print("AUTH: \(viewModel.authenticationState)")
        }
    }
}

func isValidEmail(_ email: String) -> Bool {
    // Regular expression pattern to match a standard email format
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}
