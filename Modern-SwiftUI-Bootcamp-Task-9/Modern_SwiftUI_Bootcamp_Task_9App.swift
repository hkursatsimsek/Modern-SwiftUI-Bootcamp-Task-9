//
//  Modern_SwiftUI_Bootcamp_Task_9App.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import SwiftUI
import CoreData

@main
struct Modern_SwiftUI_Bootcamp_Task_9App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
