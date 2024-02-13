//
//  GuestListFormView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

let tableType = ["None", "Hauptbar: Office", "Hauptbar: Stufe", "Hauptbar: DJ", "Hauptbar: Vor DJ", "Hauptbar: Tanzfläche", "Hauptbar: Vor Säule", "Hauptbar: Neben Säule", "Hauptbar: Hinter Säule", "New Bar: Bar Links", "New Bar: Außen", "New Bar: Toiletten", "New Bar: Bar Rechts", "Lounge: T31", "Lounge: T32", "Lounge: T33", "Lounge: T34", "Lounge: T41", "Lounge: T42", "Lounge: T43", "Lounge: T44", "Lounge: T45"]

//enum TableType: Identifiable, CaseIterable, Codable {
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
//}

struct GuestListFormView: View {
    @Environment(AuthenticationViewModel.self) var auth
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss
    @Binding var presentSheet: Bool
    var dateSelection: Date
    @State var name: String = ""
    @State var guestCount: Int = 1
    @State var tableSelection: String = "None"
    @State var isVip: Bool = false
    @State var isFreeEntry: Bool = false
    @State var isDiscount: Bool = false
    @State var additionalInfo: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                        Image(systemName: "arrowtriangle.left.circle.fill")
                    })
                Spacer()
            }
            List {
                Section {
                    TextField("Name", text: $name)
                } header: {
                    Text ("Name")
                }
                Section {
                    Stepper(value: $guestCount, in: 1...50) {
                        Text("\(guestCount)")
                    }
                } header: {
                    Text ("Total Guests")
                }
                Section {
                    Picker("Table", selection: $tableSelection) {
                        ForEach(tableType, id: \.self) { table in
                            Text("\(table.description)")
                        }
                    }
                }
                Section {
                    Toggle("VIP", isOn: $isVip)
                    Toggle("Free Entry", isOn: $isFreeEntry)
                        .onChange(of: isFreeEntry) { oldValue, newValue in
                        if newValue {
                            isDiscount = false
                        }
                    }
                    Toggle("50% Off", isOn: $isDiscount)
                        .onChange(of: isDiscount) { oldValue, newValue in
                        if newValue {
                            isFreeEntry = false
                        }
                    }
                }
                    .tint(Color(.accent))
                Section {
                    TextEditor(text: $additionalInfo)
                        .frame(minHeight: 80)
                } header: {
                    Text("Additional Info".uppercased())
                }
                Button {
                    let newGuest = Guest(uid: auth.uid, dateCreated: dateSelection, name: name, guestCount: guestCount, tableSelection: tableSelection, isVip: isVip, isFreeEntry: isFreeEntry, isDiscount: isDiscount, isArchived: false, additionalInfo: additionalInfo)
                    appState.addGuest(guest: newGuest)
                    presentSheet = false
                } label: {
                    HStack {
                        Spacer()
                        Text("ADD GUEST")
                        Spacer()
                    }
                        .foregroundStyle(Color.white)
                }
                    .listRowBackground(Color(.accent))
            }
                .padding(.top, 10)
                .background() {
                Color(.systemBackground)
            }
        }
    }
}

#Preview(body: {
    GuestListFormView(presentSheet: .constant(true), dateSelection: Date.now)
})
