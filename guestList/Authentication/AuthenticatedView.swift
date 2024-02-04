//
//  AuthenticatedView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

struct AuthenticatedView: View {
    @Environment(AuthenticationViewModel.self) var auth
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    @State var isActive: Bool = false

    var body: some View {
        Group {
            switch auth.authenticationState {
            case .authenticating:
                Color(.accent)
                    .ignoresSafeArea()
            case .unauthenticated:
                LoginView()
            case .authenticated:
                HomeTabView()
            }
        }
    }
}
