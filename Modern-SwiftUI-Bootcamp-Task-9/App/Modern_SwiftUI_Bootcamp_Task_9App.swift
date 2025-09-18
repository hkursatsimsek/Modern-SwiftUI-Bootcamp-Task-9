//
//  Modern_SwiftUI_Bootcamp_Task_9App.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import SwiftUI
import CoreData

@main
struct ModernSwiftUIBootcampTask9App: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NotesListView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}

#Preview("App Root") {
    NotesListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
