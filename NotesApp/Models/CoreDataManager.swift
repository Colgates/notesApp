//
//  CoreDataManager.swift
//  NotesApp
//
//  Created by Evgenii Kolgin on 17.07.2021.
//

import CoreData
import Foundation

class CoreDataManager {
    
    let persistentContainer: NSPersistentContainer
    
    static let shared = CoreDataManager()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Note")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("unable to initialize Core Data Stack \(error)")
            }
        }
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        saveContext()
    }
    
    func fetchContext() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            return try viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
            print(error.localizedDescription)
        }
    }
    
    func updateContext(with note: Note) {
        viewContext.insert(note)
        saveContext()
    }
}
