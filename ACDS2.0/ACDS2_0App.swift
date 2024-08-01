//
//  ACDS2_0App.swift
//  ACDS2.0
//
//  Created by Luis Angel Zapata Zuñiga on 29/07/24.
//

import SwiftUI

@main
struct ACDS2_0App: App {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some Scene {
        WindowGroup {
            LoginView().environmentObject(navigationManager)
        }
    }
}
