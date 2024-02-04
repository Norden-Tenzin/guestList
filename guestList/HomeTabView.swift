//
//  HomeTabView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftData
import SwiftUI

struct HomeTabView: View {
    @Environment(AuthenticationViewModel.self) var viewModel
    @State var selectedTab = "GuestList"

    var body: some View {
        GeometryReader(content: { geo in
            TabView(selection: $selectedTab) {
                Group {
                    GuestListView()
                        .tag("GuestList")
                        .tabItem {
                        Image(systemName: "fork.knife")
                    }
                    SettingsView()
                        .tag("Settings")
                        .tabItem {
                        Image(systemName: "person.fill")
                    }
                }
                    .toolbarBackground(Color(.bg), for: .tabBar)
            }
                .tint(Color(.accent))
        })
    }
}
