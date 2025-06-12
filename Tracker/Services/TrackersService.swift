import UIKit

// Модели данных
struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
    let isCompleted: Bool
    let isRegular: Bool
    let creationDate: Date
    
    
    func withCompletedState(_ isCompleted: Bool) -> Tracker {
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isCompleted: isCompleted,
            isRegular: isRegular,
            creationDate: creationDate
            
        )
    }
}

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    func withTrackers(_ trackers: [Tracker]) -> TrackerCategory {
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    func withAddedTracker(_ tracker: Tracker) -> TrackerCategory {
        var newTrackers = trackers
        newTrackers.append(tracker)
        return TrackerCategory(title: title, trackers: newTrackers)
    }
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}



// MARK: - Trackers Service Protocol
protocol TrackersServiceProtocol {
    var categories: [TrackerCategory] { get }
    var completedTrackers: [TrackerRecord] { get }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String)
    func completeTracker(id: UUID, date: Date)
    func uncompleteTracker(id: UUID, date: Date)
    func getTrackers(for date: Date, searchText: String?) -> [TrackerCategory]
}

// MARK: - Trackers Service Implementation
final class TrackersService: TrackersServiceProtocol {
    private(set) var categories: [TrackerCategory] = []
    private(set) var completedTrackers: [TrackerRecord] = []
    
    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore: TrackerRecordStore
    
    init(
        trackerStore: TrackerStore = TrackerStore(),
        categoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        recordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        
        trackerStore.onChange = { [weak self] in
            self?.loadInitialData()
        }
        
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        print("Adding tracker: \(tracker.title) to category: \(categoryTitle), ID: \(tracker.id)")
        do {
            let category: TrackerCategory
            if let existing = try categoryStore.category(withTitle: categoryTitle) {
                category = existing
            } else {
                category = try categoryStore.createCategory(title: categoryTitle)
            }
            
            try trackerStore.createTracker(tracker, categoryTitle: category.title)
            loadInitialData()
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }
    
    func completeTracker(id: UUID, date: Date) {
        do {
            try recordStore.addRecord(TrackerRecord(id: id, date: date))
            loadInitialData()
        } catch {
            print("Ошибка при завершении трекера: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, date: Date) {
        do {
            try recordStore.deleteRecord(TrackerRecord(id: id, date: date))
            loadInitialData()
        } catch {
            print("Ошибка при удалении записи трекера: \(error)")
        }
    }
    
    func getTrackers(for date: Date, searchText: String?) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        guard let currentWeekday = Weekday(rawValue: weekday) else { return [] }
        
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesSearch: Bool
                if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                    matchesSearch = tracker.title.lowercased().contains(searchText)
                } else {
                    matchesSearch = true
                }
                
                if !tracker.isRegular {
                    let creationDay = Calendar.current.startOfDay(for: tracker.creationDate)
                    let currentDay = Calendar.current.startOfDay(for: date)
                    
                    if tracker.isCompleted {
                        return Calendar.current.isDate(date, inSameDayAs: tracker.creationDate) && matchesSearch
                    } else {
                        return currentDay >= creationDay && matchesSearch
                    }
                }
                
                let matchesSchedule = tracker.schedule?.contains(currentWeekday) ?? true
                return matchesSearch && matchesSchedule
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    // MARK: - loadDataFromCoreData
    
    private func loadInitialData() {
        do {
            let categoriesFromStore = try categoryStore.fetchAllCategories()
            let trackersFromStore = try trackerStore.fetchAllTrackers()
            let recordsFromStore = try recordStore.fetchRecords()
            
            completedTrackers = recordsFromStore
            
            var tempCategories: [TrackerCategory] = []
            
            for category in categoriesFromStore {
                let coreDataCategory = try categoryStore.coreDataCategory(withTitle: category.title)
                let trackers = trackersFromStore.filter { tracker in
                    // Проверяем, что трекер принадлежит категории
                    coreDataCategory?.trackers?.contains { ($0 as? TrackerCoreData)?.id == tracker.id } ?? false
                }.map { tracker in
                    tracker.withCompletedState(
                        completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: tracker.creationDate) }
                    )
                }
                
                if !trackers.isEmpty {
                    tempCategories.append(TrackerCategory(title: category.title, trackers: trackers))
                }
            }
            
            categories = tempCategories
            print("Loaded \(tempCategories.count) categories with trackers: \(tempCategories.map { "\($0.title): \($0.trackers.count)" })")
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }
}
