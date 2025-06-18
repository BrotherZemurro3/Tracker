import CoreData
import Foundation
import UIKit

protocol TrackerStorable {
    func createTracker(_ tracker: Tracker, categoryTitle: String) throws
    func fetchAllTrackers() throws -> [Tracker]
    
}

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate, TrackerStorable {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    private let categoryStore: TrackerCategoryStorable
    
    var onChange: (() -> Void)?
    
    init(
        context: NSManagedObjectContext = CoreDataManager.shared.context,
        categoryStore: TrackerCategoryStorable = TrackerCategoryStore()
    ) {
        self.context = context
        self.categoryStore = categoryStore
        super.init()
        setupFetchedResultsController()
    }
    
    func createTracker(_ tracker: Tracker, categoryTitle: String) throws {
        print("Creating tracker: \(tracker.title), ID: \(tracker.id) in category: \(categoryTitle)")
        guard let categoryCoreData = try (categoryStore as? TrackerCategoryStore)?.coreDataCategory(withTitle: categoryTitle) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }
        let entity = TrackerCoreData(context: context)
        entity.id = tracker.id
        entity.title = tracker.title
        entity.colorHex = tracker.color.hexString
        entity.emoji = tracker.emoji
        entity.schedule = tracker.schedule?.map { String($0.rawValue) }.joined(separator: ",")
        entity.isRegular = tracker.isRegular
        entity.creationDate = tracker.creationDate
        entity.isPinned = tracker.isPinned
        entity.category = categoryCoreData
        print("Saving tracker: \(tracker.title) to category: \(categoryTitle)")
        try context.save()
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        let trackers = fetchedResultsController?.fetchedObjects ?? []
        return trackers.map { trackerCoreData in
            Tracker(
                id: trackerCoreData.id ?? UUID(),
                title: trackerCoreData.title ?? "",
                color: UIColor(hex: trackerCoreData.colorHex ?? "#000000") ?? .black,
                emoji: trackerCoreData.emoji ?? "",
                schedule: trackerCoreData.schedule?
                    .split(separator: ",")
                    .compactMap { Int($0) }
                    .compactMap { Weekday(rawValue: $0) },
                isCompleted: false,
                isRegular: trackerCoreData.isRegular,
                creationDate: trackerCoreData.creationDate ?? Date(),
                isPinned: trackerCoreData.isPinned
            )
        }
    }
    
    func updateTrackerPinnedState(_ trackerId: UUID, isPinned: Bool) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        guard let tracker = try context.fetch(request).first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Tracker not found"])
        }
        tracker.isPinned = isPinned
        try context.save()
        print("Updated pinned state for tracker: \(trackerId) to \(isPinned)")
    }
    
    
    func deleteTracker(_ trackerId: UUID) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        let trackers = try context.fetch(request)
        trackers.forEach { context.delete($0) }
        try context.save()
        print("Удалён трекер: \(trackerId)")
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
    
}
