//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Дионисий Коневиченко on 29.04.2025.
//
import CoreData
import Foundation

protocol TrackerCategoryStorable {
    func createCategory(title: String) throws -> TrackerCategoryCoreData
    func fetchAllCategories() throws -> [TrackerCategoryCoreData]
    func category(withTitle title: String) throws -> TrackerCategoryCoreData?
}

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func createCategory(title: String) throws -> TrackerCategoryCoreData {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
        return entity
    }
    
    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(request)
    }
    func category(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(request).first
    }
}
