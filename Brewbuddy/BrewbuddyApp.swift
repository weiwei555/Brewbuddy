//
//  BrewbuddyApp.swift
//  Brewbuddy
//
//  Created by 吴炜 on 3/16/25.
//

import SwiftUI
import SwiftData

@main
struct BrewbuddyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Drink.self,
            Nutrition.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // 设置全局外观
                    setupAppearance()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // 设置全局外观
    private func setupAppearance() {
        // 设置导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // 设置标签栏外观
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
    }
}
