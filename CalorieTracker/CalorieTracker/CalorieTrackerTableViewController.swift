//
//  CalorieTrackerTableViewController.swift
//  CalorieTracker
//
//  Created by Lambda_School_Loaner_218 on 1/31/20.
//  Copyright © 2020 Lambda_School_Loaner_218. All rights reserved.
//

import UIKit
import CoreData
import SwiftChart

class CalorieTrackerTableViewController: UITableViewController {
    
    @IBOutlet private weak var chartView: Chart!
    
    let entryController = EntryController()
    let chartSeries = ChartSeries([])
    private var loadedChartOnce = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    lazy var fetchedResultController: NSFetchedResultsController<Entry> = {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            print("error during fetching: \(error.localizedDescription)")
        }
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: .calorieEntryAdded, object: nil)
        updateViews()
    }
    
    @objc func updateViews() {
        tableView.reloadData()
        
        chartSeries.area = true
        chartSeries.color = ChartColors.redColor()
        if !loadedChartOnce {
            loadFromCoreData()
        }
        chartView.add(chartSeries)
       
    }
    
    
    private func loadFromCoreData() {
        guard let entries = fetchedResultController.fetchedObjects else { return }
        for entry in entries {
            let data = self.entryController.dataToChartSeries(for: entry.calories)
            self.chartSeries.data.append(data)
        }
        loadedChartOnce = true
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentCalorieEntryAlert()
    }
    
    private func presentCalorieEntryAlert() {
        let alert = UIAlertController(title: "Add Calorie Intake",
                                      message: "Enter amount of calories in the field",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { textField in
            textField.placeholder = "Calories"
        }
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in
            if let caloriesString = alert.textFields?.first?.text,
                !caloriesString.isEmpty,
                let calories = Float(caloriesString) {
                self.entryController.createEntry(calories: calories, timestamp: Date())
                let data = self.entryController.dataToChartSeries(for: calories)
                self.chartSeries.data.append(data)
                NotificationCenter.default.post(name: .calorieEntryAdded, object: self)
                self.dismiss(animated: true)
            }
        }))
        
        self.present(alert, animated: true)
        
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChartCell", for: indexPath)
        
        cell.textLabel?.text = "Calories: \(fetchedResultController.object(at: indexPath).calories)"
        
        let dateString = dateFormatter.string(from: fetchedResultController.object(at: indexPath).timestamp ?? Date())
        cell.detailTextLabel?.text = dateString

        return cell
    }

}

extension CalorieTrackerTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}
