//
//  GuestListView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

struct GuestListView: View {
    @Environment(AppState.self) var appState
    @State var presentPopover: Bool = false
    @State var selection: Date = Date()
    @State var presentSheet: Bool = false
    @State var searchText: String = ""
    @State var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - TOP BAR
                HStack(spacing: 15) {
                    Button(action: {
                        self.presentPopover = true
                    }) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color(.accent))
                    }
                        .buttonStyle(.plain)
                        .popover(isPresented: $presentPopover) {
                        DatePicker("", selection: $selection, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .frame(width: 350)
                            .presentationCompactAdaptation(.popover)
                            .background {
                            Color(red: 0.188, green: 0.188, blue: 0.192, opacity: 1.000)
                        }
                    }
                    Spacer()
                    Button {
                        presentSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .tint(Color(.accent))
                    }
                }
                    .frame(height: 20)
                    .overlay(content: {
                    Text(getTitleFromDate(selection: selection))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.white)
                })
                    .font(.system(size: 24))
                    .padding([.horizontal, .bottom])
                    .padding(.top, 8)

                // MARK: - WEEK BAR
                WeekBarView(selection: $selection)
                    .padding(.horizontal, 10)

                // MARK: - SEARCHBAR
                SearchBar(text: $searchText)
                    .tint(Color(.accent))
                    .padding(.top, 20)

                // MARK: - LIST
                List {
                    Section {
                        let vipGuests = appState.guests.filter { guest in
                            let isDateCorrect = (getDate(date: guest.dateCreated) == getDate(date: selection))
                            let searchFilter = searchText != "" ? guest.name.contains(searchText) : true
                            let dosentHaveTable = guest.tableSelection == "None"
                            return guest.isVip && isDateCorrect && searchFilter && !guest.isArchived && dosentHaveTable
                        }
                        ForEach(vipGuests) { guest in
                            ZStack {
                                HStack {
                                    Image("vip")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text(guest.name.capitalized)
                                    if guest.guestCount > 1 {
                                        Text("+\(guest.guestCount - 1)")
                                    }
                                    Spacer()
                                    if guest.isFreeEntry {
                                        Text("Free")
                                    } else {
                                        Image("pay")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                NavigationLink(destination: GuestDetailView(guest: guest)) {
                                    EmptyView()
                                }
                                    .opacity(0)
                            }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    Task {
                                        await appState.updateGuest(guest: guest, data: ["isArchived": true])
                                    }
                                } label: {
                                    Text("Arrived")
                                }
                                    .tint(Color.red)
                            }
                        }
                    } header: {
                        Text("VIPS")
                    }

                    Section {
                        let tabledGuests = appState.guests.filter { guest in
                            let isDateCorrect = (getDate(date: guest.dateCreated) == getDate(date: selection))
                            let searchFilter = searchText != "" ? guest.name.contains(searchText) : true
                            let doesHaveTable = guest.tableSelection != "None"
                            return isDateCorrect && searchFilter && !guest.isArchived && doesHaveTable
                        }
                        ForEach(tabledGuests) { guest in
                            ZStack {
                                HStack {
                                    Image("table")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                    Text(guest.name.capitalized)
                                    if guest.guestCount > 1 {
                                        Text("+\(guest.guestCount - 1)")
                                    }
                                    Spacer()
                                    if guest.isFreeEntry {
                                        Text("Free")
                                    } else {
                                        Image("pay")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                NavigationLink(destination: GuestDetailView(guest: guest)) {
                                    EmptyView()
                                }
                                    .opacity(0)
                            }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    Task {
                                        await appState.updateGuest(guest: guest, data: ["isArchived": true])
                                    }
                                } label: {
                                    Text("Arrived")
                                }
                                    .tint(Color.red)
                            }
                        }
                    } header: {
                        Text("TABLE RESERVATIONS")
                    }

                    Section {
                        let nonVipGuests = appState.guests.filter { guest in
                            let isDateCorrect = (getDate(date: guest.dateCreated) == getDate(date: selection))
                            let searchFilter = searchText != "" ? guest.name.contains(searchText) : true
                            let dosentHaveTable = guest.tableSelection == "None"
                            return !guest.isVip && isDateCorrect && searchFilter && !guest.isArchived && dosentHaveTable
                        }
                        ForEach(nonVipGuests) { guest in
                            ZStack {
                                HStack {
                                    Text(guest.name)
                                    if guest.guestCount > 1 {
                                        Text("+\(guest.guestCount - 1)")
                                    }
                                    Spacer()
                                    if guest.isFreeEntry {
                                        Text("Free")
                                    } else {
                                        Image("pay")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                }
                                NavigationLink(destination: GuestDetailView(guest: guest)) {
                                    EmptyView()
                                }
                                    .opacity(0)
                            }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    Task {
                                        await appState.updateGuest(guest: guest, data: ["isArchived": true])
                                    }
                                } label: {
                                    Text("Arrived")
                                }
                                    .tint(Color.red)
                            }
                        }
                    } header: {
                        Text("GUESTS")
                    }
                }
                    .animation(.default, value: appState.guests)
//                    .onChange(of: appState.guests, { old, new in
//                    withAnimation {
//                        // This block will be triggered when items change, causing an animation
//                    }
//                })
            }
                .sheet(isPresented: $presentSheet, content: {
                GuestListFormView(presentSheet: $presentSheet, dateSelection: selection)
                    .presentationDetents([.fraction(0.55)])
            })
//                .background() {
//                Color(.bg)
//                    .ignoresSafeArea()
//            }
            .onAppear() {
                appState.fetchData()
            }
        }
    }
}

#Preview {
    GuestListView()
}
