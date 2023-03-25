//
//  AppView.swift
//  SwiftUI Sidebar App
//
//  Created by Joshua Germon on 25/3/2023.
//

import SwiftUI

@main
struct AppView: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .navigationViewStyle(.automatic)
        }
    }
}
