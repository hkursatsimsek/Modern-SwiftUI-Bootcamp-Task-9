//
//  NotesRepository.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import Foundation
import CoreData
import Combine

public protocol NotesRepository {
    func create(title: String, content: String) async throws
    func update(note: NSManagedObject, title: String, content: String) async throws
    func delete(note: NSManagedObject) async throws
    func notesPublisher() -> AnyPublisher<[NSManagedObject], Never>
}

public final class CoreDataNotesRepository: NSObject, NotesRepository {
    private let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<NSManagedObject>
    private let notesSubject: CurrentValueSubject<[NSManagedObject], Never>

    public init(context: NSManagedObjectContext) {
        self.context = context
        
        // Ensure context is valid before proceeding
        guard context.persistentStoreCoordinator != nil else {
            fatalError("NSManagedObjectContext must have a valid persistentStoreCoordinator")
        }

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)

        notesSubject = CurrentValueSubject<[NSManagedObject], Never>([])

        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            notesSubject.value = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("CoreDataNotesRepository: Failed to perform initial fetch: \(error)")
            notesSubject.value = []
        }
    }

    public func create(title: String, content: String) async throws {
        try await context.perform {
            guard let entity = NSEntityDescription.entity(forEntityName: "NoteEntity", in: self.context) else {
                throw NSError(domain: "CoreDataNotesRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing Core Data entity 'NoteEntity'"])
            }
            let newNote = NSManagedObject(entity: entity, insertInto: self.context)
            newNote.setValue(UUID(), forKey: "id")
            newNote.setValue(title, forKey: "title")
            newNote.setValue(content, forKey: "content")
            newNote.setValue(Date(), forKey: "date")
            try self.context.save()
        }
    }

    public func update(note: NSManagedObject, title: String, content: String) async throws {
        try await context.perform {
            note.setValue(title, forKey: "title")
            note.setValue(content, forKey: "content")
            note.setValue(Date(), forKey: "date")
            try self.context.save()
        }
    }

    public func delete(note: NSManagedObject) async throws {
        try await context.perform {
            self.context.delete(note)
            try self.context.save()
        }
    }

    public func notesPublisher() -> AnyPublisher<[NSManagedObject], Never> {
        return notesSubject.eraseToAnyPublisher()
    }
}

extension CoreDataNotesRepository: NSFetchedResultsControllerDelegate {
    @objc public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let notes = fetchedResultsController.fetchedObjects ?? []
        notesSubject.send(notes)
    }
}
