//
//  NewNoteViewModel.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import Foundation
import Combine

@MainActor
final class NewNoteViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""

    private let repository: NotesRepository

    init(repository: NotesRepository) {
        self.repository = repository
    }

    var canSave: Bool { !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func save() async throws {
        try await repository.create(title: title, content: content)
    }
}
