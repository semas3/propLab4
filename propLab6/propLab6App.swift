//
//  propLab6App.swift
//  propLab6
//
//  Created by student on 27.12.2023.
//

import SwiftUI

@main
struct propLab6App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
