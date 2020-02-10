//
//  Entry+Convenience.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_218 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_218. All rights reserved.
//

import Foundation
import CoreData

extension Entry {
    @discardableResult convenience init(calories: Float, timestamp: Date, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        self.init(context: context)
        self.calories = calories
        self.timestamp = timestamp
    }
    
    @discardableResult convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(calories: entryRepresentation.calories, timestamp: entryRepresentation.timestamp, context: context)
    }
    
    var entryRepresenetation: EntryRepresentation? {
        guard let timestamp = timestamp else { return nil }
        return EntryRepresentation(calories: calories, timestamp: timestamp)
    }
}
