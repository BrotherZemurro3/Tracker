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

final class TrackerStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }

    func createTracker(from model: Tracker, category: TrackerCategoryCoreData) throws {
        let entity = TrackerCoreData(context: context)
        entity.id = model.id
        entity.title = model.title
        entity.colorHex = model.color.hexString
        entity.emoji = model.emoji
        entity.schedule = model.schedule?.map { String($0.rawValue) }.joined(separator: ",")
        entity.isRegular = model.isRegular
        entity.category = category
        try context.save()
    }

    func fetchAllTrackers() throws -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        return try context.fetch(request)
    }

}

