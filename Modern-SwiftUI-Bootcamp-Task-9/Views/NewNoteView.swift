//
//  NewNoteView.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import SwiftUI
import CoreData

struct NewNoteView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: NewNoteViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Başlık") {
                    TextField("Zorunlu", text: $viewModel.title)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled(false)
                }
                Section("İçerik") {
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 180)
                }
            }
            .navigationTitle("Yeni Not")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Vazgeç") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kaydet") {
                        Task {
                            do {
                                try await viewModel.save()
                                dismiss()
                            } catch {
                                print("Save error: \(error)")
                            }
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

#Preview {
    NewNoteView(viewModel: NewNoteViewModel(repository: CoreDataNotesRepository(context: PersistenceController.preview.container.viewContext)))
}
