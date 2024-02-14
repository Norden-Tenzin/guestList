//
//  GuestDetailView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/4/24.
//

import SwiftUI

struct GuestDetailView: View {
    @Environment(AppState.self) var appState
    var guest: Guest

    @State var authorName: String = ""
    @State var presentSheet: Bool = false

    var body: some View {
        List {
            Section {
                Text(guest.name.capitalized)
            } header: {
                Text("Guest Name")
                    .foregroundStyle(Color(.accent))
            }

            Section {
                Button(action: {
                    presentSheet = true
                }, label: {
                        Text(guest.tableSelection.description)
                    })
            } header: {
                Text("Reserved Table")
                    .foregroundStyle(Color(.accent))
            }

            Section {
                Text(guest.additionalInfo)
            } header: {
                Text("Additional Info")
                    .foregroundStyle(Color(.accent))
            }

            Section {
                Text(authorName)
            } header: {
                Text("Author")
                    .foregroundStyle(Color(.accent))
            }
        }
            .onAppear() {
            Task {
                authorName = await appState.getNameFromUID(uid: guest.uid)
            }
        }
            .sheet(isPresented: $presentSheet, content: {
                TableDetailView(table: guest.tableSelection.description, presentSheet: $presentSheet)
        })
    }
}
