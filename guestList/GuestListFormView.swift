//
//  GuestListFormView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

let tableType = [
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
    "Lounge: T45": "LT45"
]

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
                        ForEach(Array(tableType.keys), id: \.self) { table in
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
