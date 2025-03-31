import UIKit

// Модели данных
struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
    var isCompleted: Bool = false
}

struct TrackerCategory {
    let title: String
    var trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}

enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

// Протокол для сервиса
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
    
    init() {
        // Инициализация без тестовых данных
    }
    
    // MARK: - Public Methods
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            categories[index].trackers.append(tracker)
        } else {
            categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        }
        
        print("Сервис обновлён, категорий: \(categories.count), трекеров в первой: \(categories.first?.trackers.count ?? 0)")
    }
    
    func completeTracker(id: UUID, date: Date) {
        // Находим трекер по ID и отмечаем как выполненный
        for (categoryIndex, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == id }) {
                var updatedTracker = category.trackers[trackerIndex]
                updatedTracker.isCompleted = true
                
                var updatedTrackers = category.trackers
                updatedTrackers[trackerIndex] = updatedTracker
                
                categories[categoryIndex].trackers = updatedTrackers
                completedTrackers.append(TrackerRecord(id: id, date: date))
                break
            }
        }
    }
    
    func uncompleteTracker(id: UUID, date: Date) {
        // Находим трекер по ID и отмечаем как невыполненный
        for (categoryIndex, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == id }) {
                var updatedTracker = category.trackers[trackerIndex]
                updatedTracker.isCompleted = false
                
                var updatedTrackers = category.trackers
                updatedTrackers[trackerIndex] = updatedTracker
                
                categories[categoryIndex].trackers = updatedTrackers
                completedTrackers.removeAll { $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
                break
            }
        }
    }
    
    func getTrackers(for date: Date, searchText: String? = nil) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        let currentWeekday = Weekday(rawValue: weekday)!
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                // Фильтрация по поисковому запросу
                let matchesSearch = searchText == nil ||
                                 tracker.title.lowercased().contains(searchText!.lowercased())
                
                // Фильтрация по расписанию
                let matchesSchedule: Bool
                if let schedule = tracker.schedule {
                    matchesSchedule = schedule.contains(currentWeekday)
                } else {
                    // Нерегулярные события показываются всегда
                    matchesSchedule = true
                }
                
                return matchesSearch && matchesSchedule
            }
            
            // Возвращаем только категории с отфильтрованными трекерами
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
    }
}
