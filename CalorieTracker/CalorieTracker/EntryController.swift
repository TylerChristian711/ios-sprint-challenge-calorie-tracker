//
//  EntryController.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_218 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_218. All rights reserved.
//
import CoreData
import Foundation

class EntryController {
    private var xAxis: Double = 0
    
    func createEntry(calories: Float, timestamp:Date) {
        Entry(calories: calories, timestamp: timestamp)
        do {
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
        } catch {
            print("error saving entry: \(error.localizedDescription)")
        }
    }
    
    func dataToChartSeries(for calories: Float) -> (Double,Double) {
        let data = (xAxis, Double(calories))
        xAxis += 1
        return data 
    }
}
