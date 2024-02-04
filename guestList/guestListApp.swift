//
//  guestListApp.swift
//  guestList
//
//  Created by Tenzin Norden on 2/3/24.
//

import SwiftUI

@main
struct guestListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environment(AuthenticationViewModel(fcm: delegate.fcm))
        }
    }
}
