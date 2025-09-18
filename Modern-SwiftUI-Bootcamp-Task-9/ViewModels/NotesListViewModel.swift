//
//  NotesListViewModel.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import Foundation
import Combine
import CoreData

@MainActor
final class NotesListViewModel: ObservableObject {
    @Published var searchText: String = ""

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Repository will be injected from view when needed
    }

    /// Delete using Core Data object directly to match repository API
    func delete(note: NSManagedObject, using repository: NotesRepository) async {
        do {
            try await repository.delete(note: note)
        } catch {
            print("Delete error: \(error)")
        }
    }
}
