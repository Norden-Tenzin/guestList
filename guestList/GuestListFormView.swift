//
//  GuestListFormView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

// enum TableType: Identifiable, CaseIterable, Codable {
//    case None
//    case dj
//
//    var id: Self {
//        return self
//    }
//
//    var description: String {
//        switch self {
//        case .None: return "None"
//        case .dj: return "DJ Table"
//        }
//    }
// }

func getAvailableTables(guest: Guest, guests: [Guest], dateSelection: Date) -> [String: String] {
    var tableType = [
        "None": "None",
        "Hauptbar: Office": "HT1",
        "Hauptbar: Stufe": "HT2",
        "Hauptbar: DJ": "HT3",
        "Hauptbar: Vor DJ": "HT4",
        "Hauptbar: Tanzfläche": "HT5",
        "Hauptbar: Vor Säule": "HT6",
        "Hauptbar: Neben Säule": "HT7",
        "Hauptbar: Hinter Säule": "HT8",
        "New Bar: Bar Links": "NT21",
        "New Bar: Außen": "NT22",
        "New Bar: Toiletten": "NT23",
        "New Bar: Bar Rechts": "NT24",
        "Lounge: T31": "LT31",
        "Lounge: T32": "LT32",
        "Lounge: T33": "LT33",
        "Lounge: T34": "LT34",
        "Lounge: T41": "LT41",
        "Lounge: T42": "LT42",
        "Lounge: T43": "LT43",
        "Lounge: T44": "LT44",
        "Lounge: T45": "LT45",
    ]
    let selectionGuests = guests.filter { guest in
        let isDateCorrect = (getDate(date: guest.dateCreated) == getDate(date: dateSelection))
        return isDateCorrect && !guest.isArchived
    }
    for selectedGuest in selectionGuests {
        if selectedGuest.tableSelection == "None" {
            continue
        }
        if guest.tableSelection != selectedGuest.tableSelection {
            tableType.removeValue(forKey: selectedGuest.tableSelection)
        }
    }
    return tableType
}

enum FormType {
    case edit
    case add
}

struct GuestListFormView: View {
    @Environment(AuthenticationViewModel.self) var auth
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss
    @Binding var presentSheet: Bool
    @State var guest: Guest
    var dateSelection: Date
    let formType: FormType

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "arrowtriangle.left.circle.fill")
                        .font(.system(size: 24))
                })
                .padding([.leading, .top], 15)
                Spacer()
            }
            List {
                Section {
                    TextField("Name", text: $guest.name)
                } header: {
                    Text("Name")
                }
                Section {
                    Stepper(value: $guest.guestCount, in: 1 ... 50) {
                        Text("\(guest.guestCount)")
                    }
                } header: {
                    Text("Total Guests")
                }
                Section {
                    Picker("Table", selection: $guest.tableSelection) {
                        ForEach(getAvailableTables(guest: guest, guests: appState.guests, dateSelection: dateSelection).sorted(by: >), id: \.key) { key, _ in
                            Text("\(key)")
                        }
                    }
                }
                Section {
                    Toggle("PERMANENT GUEST", isOn: $guest.isVip)
                    Toggle("Free Entry", isOn: $guest.isFreeEntry)
                        .onChange(of: guest.isFreeEntry) { _, newValue in
                            if newValue {
                                guest.isDiscount = false
                            }
                        }
                    Toggle("50% Off", isOn: $guest.isDiscount)
                        .onChange(of: guest.isDiscount) { _, newValue in
                            if newValue {
                                guest.isFreeEntry = false
                            }
                        }
                }
                .tint(Color(.accent))
                Section {
                    TextEditor(text: $guest.additionalInfo)
                        .frame(minHeight: 80)
                } header: {
                    Text("Additional Info".uppercased())
                }
                Button {
                    if formType == .add {
                        Task {
                            await appState.addGuest(guest: guest)
                        }
                    } else if formType == .edit {
                        guest.uid = auth.uid
                        Task {
                            await appState.updateGuest(guest: guest)
                        }
                    }
                    presentSheet = false
                } label: {
                    HStack {
                        Spacer()
                        if formType == .add {
                            Text("ADD GUEST")
                        } else {
                            Text("SAVE GUEST")
                        }
                        Spacer()
                    }
                    .foregroundStyle(Color.white)
                }
                .listRowBackground(Color(.accent))
            }
            .padding(.top, 10)
            .background {
                Color(.systemBackground)
            }
        }
    }
}
