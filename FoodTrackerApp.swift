//
//  FoodTrackerApp.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI
import SwiftData

@main
struct FoodTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SearchView()
            }
            .modelContainer(for: Foodstuffs.self)
        }
    }
}
