//
//  NoteEntity+CoreDataProperties.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//
//

public import Foundation
public import CoreData


public typealias NoteEntityCoreDataPropertiesSet = NSSet

extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var date: Date?

}

extension NoteEntity : Identifiable {

}
