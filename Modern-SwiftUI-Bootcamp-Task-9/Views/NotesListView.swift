//
//  NotesListView.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import SwiftUI
import CoreData

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var context

    @StateObject private var viewModel = NotesListViewModel()
    @State private var isPresentingNew: Bool = false
    
    @FetchRequest(
        entity: NSEntityDescription.entity(forEntityName: "NoteEntity", 
                                         in: PersistenceController.shared.container.viewContext)!,
        sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)]
    ) private var allNotes: FetchedResults<NSManagedObject>
    
    private var repository: NotesRepository {
        CoreDataNotesRepository(context: context)
    }
    
    // Filtered notes based on search text
    private var filteredNotes: [NSManagedObject] {
        let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return Array(allNotes)
        } else {
            return allNotes.filter { note in
                if let title = note.value(forKey: "title") as? String {
                    return title.localizedCaseInsensitiveContains(trimmed)
                }
                return false
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredNotes, id: \.objectID) { note in
                    NavigationLink(value: note.objectID) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text((note.value(forKey: "title") as? String) ?? "Untitled")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if let date = note.value(forKey: "date") as? Date {
                                Text(date, style: .date)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(((note.value(forKey: "title") as? String) ?? "Untitled")), \(((note.value(forKey: "date") as? Date) ?? Date()).formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Notlar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingNew = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Yeni Not Ekle")
                }
            }
            .sheet(isPresented: $isPresentingNew) {
                NewNoteView(viewModel: NewNoteViewModel(repository: repository))
            }
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: Text("Başlığa göre ara"))
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                if let note = try? context.existingObject(with: objectID) {
                    NoteDetailView(viewModel: NoteDetailViewModel(note: note, repository: repository))
                } else {
                    Text("Not bulunamadı")
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        Task { @MainActor in
            let toDelete = offsets.map { filteredNotes[$0] }
            for note in toDelete {
                await viewModel.delete(note: note, using: repository)
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    return NotesListView()
        .environment(\.managedObjectContext, context)
}
