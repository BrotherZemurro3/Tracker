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
        if #available(iOS 15.0, *) {
            try context.performAndWait {
                let recordEntity = TrackerRecordCoreData(context: context)
                recordEntity.id = record.id
                recordEntity.date = record.date
                do {
                    try context.save()
                    print("Added record at \(Date()): ID: \(record.id), Date: \(record.date)")
                } catch {
                    print("Error saving record at \(Date()): \(error)")
                    throw error
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        if #available(iOS 15.0, *) {
            try context.performAndWait {
                let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as CVarArg, record.date as NSDate)
                do {
                    let records = try context.fetch(request)
                    records.forEach { context.delete($0) }
                    try context.save()
                    print("Deleted record at \(Date()): ID: \(record.id), Date: \(record.date)")
                } catch {
                    print("Error deleting record at \(Date()): \(error)")
                    throw error
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        var records: [TrackerRecord] = []
        if #available(iOS 15.0, *) {
            try context.performAndWait {
                let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
                request.returnsObjectsAsFaults = false
                do {
                    let coreDataRecords = try context.fetch(request)
                    records = coreDataRecords.compactMap { record in
                        guard let id = record.id, let date = record.date else {
                            print("Invalid record found: ID: \(record.id?.uuidString ?? "nil"), Date: \(record.date?.description ?? "nil")")
                            return nil
                        }
                        return TrackerRecord(id: id, date: date)
                    }
                    print("Fetched records at \(Date()): \(records.map { "ID: \($0.id), Date: \($0.date)" })")
                } catch {
                    print("Error fetching records at \(Date()): \(error)")
                    throw error
                }
            }
        } else {
            // Fallback on earlier versions
        }
        return records
    }
}
