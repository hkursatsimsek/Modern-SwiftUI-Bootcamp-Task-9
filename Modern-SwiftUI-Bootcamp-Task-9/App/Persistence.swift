//
//  Persistence.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import CoreData
import Foundation

public final class PersistenceController {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    // MARK: - Init
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Note")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        var loadError: Error?
        
        container.loadPersistentStores { _, error in
            if let error = error {
                loadError = error
                print("CoreData: Failed to load persistent stores: \(error)")
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let error = loadError {
            fatalError("CoreData: Unresolved error loading persistent stores: \(error)")
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Preview helper
    public static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        return controller
    }()
}

public extension NSManagedObjectContext {
    func saveIfNeeded() throws {
        if hasChanges {
            try save()
        }
    }

    func performAndSave(_ block: @escaping (NSManagedObjectContext) throws -> Void) async throws {
        try await perform {
            try block(self)
            try self.saveIfNeeded()
        }
    }
}
