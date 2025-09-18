//
//  NoteDetailViewModel.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import Foundation
import CoreData
import Combine

@MainActor
final class NoteDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    
    // Store original values for cancel functionality
    private let originalTitle: String
    private let originalContent: String

    var date: Date? {
        managedNote.value(forKey: "date") as? Date
    }

    var id: UUID? {
        managedNote.value(forKey: "id") as? UUID
    }

    private let managedNote: NSManagedObject
    private let repository: NotesRepository

    init(note: NSManagedObject, repository: NotesRepository) {
        self.managedNote = note
        self.repository = repository
        let currentTitle = note.value(forKey: "title") as? String ?? ""
        let currentContent = note.value(forKey: "content") as? String ?? ""
        
        self.title = currentTitle
        self.content = currentContent
        self.originalTitle = currentTitle
        self.originalContent = currentContent
    }

    var canSave: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// Saves the current title and content.
    /// The repository is responsible for updating the note's date if needed.
    func save() async throws {
        try await repository.update(note: managedNote, title: title, content: content)
    }
    
    /// Cancels any changes and reverts to original values
    func cancelChanges() {
        title = originalTitle
        content = originalContent
    }
    
    /// Deletes the note
    func delete() async throws {
        try await repository.delete(note: managedNote)
    }
}
