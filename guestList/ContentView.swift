//
//  ContentView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

struct ContentView: View {
    @State var isActive: Bool = false
    @State var appState: AppState = AppState()

    var body: some View {
        ZStack {
            if self.isActive {
                AuthenticatedView()
                    .environment(appState)
            } else {
                Color.black
                    .overlay(content: {
                    Image("haferl_logo")
                        .frame(width: 200, height: 200)
                })
                    .ignoresSafeArea()
            }
        }
            .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.isActive = true
                }
            }
        }
    }
}
