//
//  SplashView.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

struct SplashView: View {
    @State var isActive: Bool = false
    @State var appState: AppState = AppState()

    var body: some View {
        ZStack {
            if self.isActive {
                AuthenticatedView()
                    .environment(appState)
            } else {
                Color.black
                    .ignoresSafeArea()
            }
        }
            .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    self.isActive = true
                }
            }
        }
    }
}
