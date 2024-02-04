//
//  SettingsView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AuthenticationViewModel.self) var viewModel
    @State var showAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("\(viewModel.firstName) \(viewModel.lastName)")
                            Text(viewModel.email)
                        }
                    }
                }
                    .listRowBackground(Color(.cardBg))
                Section {
                    Button {
                        showAlert = true
                    } label: {
                        Text("Sign Out")
                    }
                }
                    .listRowBackground(Color(.cardBg))
            }
                .navigationTitle("Settings")
                .scrollContentBackground(.hidden)
                .background() {
                Color(.bg)
                    .ignoresSafeArea()
            }
        }
            .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Are you sure you want to Signout?"),
                primaryButton: Alert.Button.destructive(Text("Yes"), action: {
                        viewModel.signOut()
                    }),
                secondaryButton: Alert.Button.cancel())
        })
    }
}
