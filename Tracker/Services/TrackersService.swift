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
        do {
            let categoryCoreData: TrackerCategoryCoreData
            if let existing = try categoryStore.category(withTitle: categoryTitle) {
                categoryCoreData = existing
            } else {
                categoryCoreData = try categoryStore.createCategory(title: categoryTitle)
            }
            
            try trackerStore.createTracker(from: tracker, category: categoryCoreData)
            loadInitialData()
        } catch {
            print("Ошибка при добавлении трекера: \(error)")
        }
    }
    
    func completeTracker(id: UUID, date: Date) {
        do {
            try recordStore.addRecord(for: id, date: date)
            loadInitialData()
        } catch {
            print("Ошибка при завершении трекера: \(error)")
        }
    }
    
    func uncompleteTracker(id: UUID, date: Date) {
        do {
            try recordStore.deleteRecord(for: id, date: date)
            loadInitialData()
        } catch {
            print("[TrackerSerОшибка при удалении записи трекера: \(error)")
        }
    }
    
    func getTrackers(for date: Date, searchText: String?) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        guard let currentWeekday = Weekday(rawValue: weekday) else { return [] }
        
        return categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesSearch = searchText == nil || tracker.title.lowercased().contains(searchText!.lowercased())
                
                if !tracker.isRegular {
                    // Для нерегулярных трекеров
                    let creationDay = Calendar.current.startOfDay(for: tracker.creationDate)
                    let currentDay = Calendar.current.startOfDay(for: date)
                    
                    // Если трекер уже был выполнен, показываем только в день создания
                    if tracker.isCompleted {
                        return Calendar.current.isDate(date, inSameDayAs: tracker.creationDate) && matchesSearch
                    }
                    // Если не выполнен, показываем начиная с дня создания и далее
                    else {
                        return currentDay >= creationDay && matchesSearch
                    }
                }
                
                // Для регулярных трекеров
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
            let trackerCoreDataList = try trackerStore.fetchAllTrackers()
            let recordCoreDataList = try recordStore.fetchRecords()
            
            completedTrackers = recordCoreDataList.map {
                TrackerRecord(id: $0.id ?? UUID(), date: $0.date ?? Date())
            }
            
            var tempCategories: [TrackerCategory] = []
            
            for category in categoriesFromStore {
                guard let trackerSet = category.trackers as? Set<TrackerCoreData> else { continue }
                
                let trackers = trackerSet.map { trackerCoreData in
                    Tracker(
                        id: trackerCoreData.id ?? UUID(),
                        title: trackerCoreData.title ?? "",
                        color: UIColor(hex: trackerCoreData.colorHex ?? "#000000") ?? .black,
                        emoji: trackerCoreData.emoji ?? "",
                        schedule: trackerCoreData.schedule?
                            .split(separator: ",")
                            .compactMap { Int($0) }
                            .compactMap { Weekday(rawValue: $0) },
                        isCompleted: completedTrackers.contains { $0.id == trackerCoreData.id },
                        isRegular: trackerCoreData.isRegular,
                        creationDate: trackerCoreData.creationDate ?? Date()
                    )
                }
                
                tempCategories.append(TrackerCategory(title: category.title ?? "", trackers: trackers))
            }
            
            categories = tempCategories
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }
}
