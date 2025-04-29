//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Дионисий Коневиченко on 29.04.2025.
//
import CoreData
import Foundation

protocol TrackerRecordStorable {
    func addRecord(for trackedID: UUID, date: Date) throws
    func deleteRecord(for trackerID: UUID, date: Date) throws
    func fetchRecords() throws -> [TrackerRecordCoreData]
}


final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func addRecord(for trackedID: UUID, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.id = trackedID
        record.date = date
        try context.save()
    }
    
    func deleteRecord(for trackerID: UUID, date: Date) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerID as CVarArg, date as NSDate)
        
        let records = try context.fetch(request)
        records.forEach { context.delete($0) }
        try context.save()
    }
    
    func fetchRecords() throws -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        return try context.fetch(request)
    }
    
}

