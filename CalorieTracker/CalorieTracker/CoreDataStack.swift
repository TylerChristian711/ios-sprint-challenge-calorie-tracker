//
//  CoreDataStack.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_218 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_218. All rights reserved.
//
import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CalorieTracker")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("failed to load presistents store :\(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext) throws {
       
        var error: Error?
        
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        if let error = error { throw error }
    }
    
}
