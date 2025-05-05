import CoreData
import Foundation

protocol TrackerCategoryStorable {
    func createCategory(title: String) throws -> TrackerCategory
    func fetchAllCategories() throws -> [TrackerCategory]
    func category(withTitle title: String) throws -> TrackerCategory?
}

final class TrackerCategoryStore: TrackerCategoryStorable {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
    
    func createCategory(title: String) throws -> TrackerCategory {
        let entity = TrackerCategoryCoreData(context: context)
        entity.title = title
        try context.save()
        return TrackerCategory(title: title, trackers: [])
    }
    
    func fetchAllCategories() throws -> [TrackerCategory] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let coreDataCategories = try context.fetch(request)
        return coreDataCategories.map { category in
            TrackerCategory(
                title: category.title ?? "",
                trackers: []
            )
        }
    }
    
    func category(withTitle title: String) throws -> TrackerCategory? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        guard let coreDataCategory = try context.fetch(request).first else { return nil }
        return TrackerCategory(title: coreDataCategory.title ?? "", trackers: [])
    }
    
    
    internal func coreDataCategory(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(request).first
    }
}
