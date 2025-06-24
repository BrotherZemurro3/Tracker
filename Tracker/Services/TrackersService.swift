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
    let isPinned: Bool
    
    
    func withCompletedState(_ isCompleted: Bool) -> Tracker {
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isCompleted: isCompleted,
            isRegular: isRegular,
            creationDate: creationDate,
            isPinned: isPinned
            
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
    func updateTracker(_ tracker: Tracker, in categoryTitle: String, oldCategoryTitle: String?)
    func getTrackers(for date: Date, searchText: String?) -> [TrackerCategory]
    func deleteTracker(_ trackerId: UUID)
    func pinTracker(_ trackerId: UUID)
    func unpinTracker(_ trackerId: UUID)
}

// MARK: - Trackers Service Implementation
final class TrackersService: TrackersServiceProtocol {
    static let shared = TrackersService()
    private(set) var categories: [TrackerCategory] = []
    private(set) var completedTrackers: [TrackerRecord] = []
    weak var statisticsUpdater: StatisticsUpdater? // Добавляем свойство
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: CoreDataManager.shared.context
        )
        loadInitialData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Public Methods
    @objc private func contextDidSave() {
        print("Received NSManagedObjectContextDidSave at \(Date())")
        loadInitialData()
    }
    
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
    func updateTracker(_ tracker: Tracker, in categoryTitle: String, oldCategoryTitle: String?) {
        print("Updating tracker: \(tracker.title) to category: \(categoryTitle), ID: \(tracker.id)")
        do {
            if oldCategoryTitle != categoryTitle {
                // Ensure new category exists
                if try categoryStore.category(withTitle: categoryTitle) == nil {
                    _ = try categoryStore.createCategory(title: categoryTitle)
                }
            }
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
            loadInitialData()
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
        }
    }
    func deleteTracker(_ trackerId: UUID) {
        do {
            let records = try recordStore.fetchRecords().filter { $0.id == trackerId }
            try records.forEach { try recordStore.deleteRecord($0) }
            try trackerStore.deleteTracker(trackerId)
            loadInitialData()
        } catch {
            print("Ошибка при удалении трекера: \(error)")
        }
    }
    
    func completeTracker(id: UUID, date: Date) {
        do {
            try recordStore.addRecord(TrackerRecord(id: id, date: date))
            loadInitialData() // Загружаем данные синхронно
            print("After completeTracker, completedTrackers: \(completedTrackers.map { "ID: \($0.id), Date: \($0.date)" })")
            statisticsUpdater?.updateStatistics()
            NotificationCenter.default.post(name: NSNotification.Name("TrackerCompletedNotification"), object: nil)
        } catch {
            print("Ошибка при завершении трекера: \(error)")
        }
    }
    func uncompleteTracker(id: UUID, date: Date) {
        do {
            try recordStore.deleteRecord(TrackerRecord(id: id, date: date))
            loadInitialData() // Загружаем данные синхронно
            print("After uncompleteTracker, completedTrackers: \(completedTrackers.map { "ID: \($0.id), Date: \($0.date)" })")
            statisticsUpdater?.updateStatistics()
            NotificationCenter.default.post(name: NSNotification.Name("TrackerCompletedNotification"), object: nil)
        } catch {
            print("Ошибка при удалении записи трекера: \(error)")
        }
    }
    func pinTracker(_ trackerId: UUID) {
        do {
            try trackerStore.updateTrackerPinnedState(trackerId, isPinned: true)
            loadInitialData()
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    func unpinTracker(_ trackerId: UUID) {
        do {
            try trackerStore.updateTrackerPinnedState(trackerId, isPinned: false)
            loadInitialData()
        } catch {
            print("Ошибка при откреплении трекера: \(error)")
        }
    }
    
    func getTrackers(for date: Date, searchText: String?) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        guard let currentWeekday = Weekday(rawValue: weekday) else { return [] }
        
        let filteredCategories = categories.compactMap { category in
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
            let sortedTrackers = trackers.sorted { $0.isPinned && !$1.isPinned }
            return sortedTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: sortedTrackers)
        }
        return filteredCategories
    }
    
    // MARK: - loadDataFromCoreData
    
    private func loadInitialData() {
        do {
            let categoriesFromStore = try categoryStore.fetchAllCategories()
            let trackersFromStore = try trackerStore.fetchAllTrackers()
            let recordsFromStore = try recordStore.fetchRecords()
            
            completedTrackers = recordsFromStore
            print("Loaded completedTrackers: \(recordsFromStore.map { "ID: \($0.id), Date: \($0.date)" })")
            
            var tempCategories: [TrackerCategory] = []
            
            for category in categoriesFromStore {
                let coreDataCategory = try categoryStore.coreDataCategory(withTitle: category.title)
                let trackers = trackersFromStore.filter { tracker in
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
            statisticsUpdater?.updateStatistics()
            print("Loaded \(tempCategories.count) categories with trackers: \(tempCategories.map { "\($0.title): \($0.trackers.count)" })")
            

            NotificationCenter.default.post(name: NSNotification.Name("TrackerCompletedNotification"), object: nil)
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }}
