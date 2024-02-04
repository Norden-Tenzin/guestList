//
//  GuestDetailView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/4/24.
//

import SwiftUI

struct GuestDetailView: View {
    var guest: Guest

    var body: some View {
        List {
            Section {
                Text(guest.name)
            } header: {
                Text("Guest Name")
                    .foregroundStyle(Color(.accent))
            }
            
            Section {
                Text(guest.guestCount.description)
            } header: {
                Text("Total Number Of Guests")
                    .foregroundStyle(Color(.accent))
            }
            
            Section {
                Text(guest.tableSelection.description)
            } header: {
                Text("Reserved Table")
                    .foregroundStyle(Color(.accent))
            }
            
            Section {
                Text(guest.isVip ? "VIP" : "Guest")
            } header: {
                Text("Guest Status")
                    .foregroundStyle(Color(.accent))
            }
            
            Section {
                if guest.isFreeEntry {
                    Text("Free")
                }
                if guest.isDiscount {
                    Text("50/50")
                }
            } header: {
                Text("Entry Fee")
                    .foregroundStyle(Color(.accent))
            }
        }
    }
}
