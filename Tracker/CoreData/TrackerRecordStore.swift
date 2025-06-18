import CoreData
import Foundation

protocol TrackerRecordStorable {
    func addRecord(_ record: TrackerRecord) throws
    func deleteRecord(_ record: TrackerRecord) throws
    func fetchRecords() throws -> [TrackerRecord]
}

final class TrackerRecordStore: TrackerRecordStorable {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        let recordEntity = TrackerRecordCoreData(context: context)
        recordEntity.id = record.id
        recordEntity.date = record.date
        try context.save()
        print("Added record: ID: \(record.id), Date: \(record.date)")
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as CVarArg, record.date as NSDate)
        
        let records = try context.fetch(request)
        records.forEach { context.delete($0) }
        try context.save()
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let coreDataRecords = try context.fetch(request)
        return coreDataRecords.map { record in
            TrackerRecord(id: record.id ?? UUID(), date: record.date ?? Date())
            
        }
    }
}
