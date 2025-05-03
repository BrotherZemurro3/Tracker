//
//  TrackerStore.swift
//  Tracker
//
//  Created by Дионисий Коневиченко on 29.04.2025.
//

import CoreData
import Foundation
import CoreData
import UIKit


protocol TrackerStorable {
    func createTracker(from model: Tracker, category: TrackerCategoryCoreData) throws
    func fetchAllTrackers() throws -> [TrackerCoreData]
}

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    var onChange: (() -> Void)? // Коллбек для ViewModel

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    func createTracker(from model: Tracker, category: TrackerCategoryCoreData) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = model.id
        entity.title = model.title
        entity.colorHex = model.color.hexString
        entity.emoji = model.emoji
        entity.schedule = model.schedule?.map { String($0.rawValue) }.joined(separator: ",")
        entity.isRegular = model.isRegular
        entity.creationDate = model.creationDate
        entity.category = category
        try context.save()
    }
    private func setupFetchedResultsController() {
           let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
           request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

           fetchedResultsController = NSFetchedResultsController(
               fetchRequest: request,
               managedObjectContext: context,
               sectionNameKeyPath: nil,
               cacheName: nil
           )
           fetchedResultsController?.delegate = self

           do {
               try fetchedResultsController?.performFetch()
           } catch {
               print("Ошибка при выполнении fetch: \(error)")
           }
       }

       func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           onChange?()
       }

       func fetchAllTrackers() throws -> [TrackerCoreData] {
           return fetchedResultsController?.fetchedObjects ?? []
       }
   }


