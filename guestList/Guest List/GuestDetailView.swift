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
    @State var presentTableDetail: Bool = false
    @State var presentEditFormView: Bool = false
    var dateSelection: Date

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
                    presentTableDetail = true
                }, label: {
                    Text(guest.tableSelection.description)
                })
                .sheet(isPresented: $presentTableDetail, content: {
                    TableDetailView(table: guest.tableSelection.description, presentSheet: $presentTableDetail)
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
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing, content: {
                Button {
                    presentEditFormView = true
                } label: {
                    Text("Edit")
                }
                .sheet(isPresented: $presentEditFormView, content: {
                    GuestListFormView(presentSheet: $presentEditFormView, guest: guest, dateSelection: dateSelection, formType: .edit)
                })
            })
        })
        .onAppear {
            Task {
                authorName = await appState.getNameFromUID(uid: guest.uid)
            }
        }
    }
}
