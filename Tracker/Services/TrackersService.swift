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
    let shouldRemoveAfterCompletion: Bool
    
    func withCompletedState(_ isCompleted: Bool) -> Tracker {
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isCompleted: isCompleted,
            isRegular: isRegular,
            shouldRemoveAfterCompletion: shouldRemoveAfterCompletion
            // добавил shouldRemoveAfterCompletion на будущее, что бы реализовать
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
    
    init() {}
    
    // MARK: - Public Methods
    // Поиск трекера и добавление в категорию
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            categories[index] = TrackerCategory(title: categoryTitle, trackers: updatedTrackers)
        } else {
            categories.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        }
        print("Трекер добавлен. Всего категорий: \(categories.count)")
    }
    // Проверка выполнения трекера
    func completeTracker(id: UUID, date: Date) {
        // Проверяем, не выполнен ли уже трекер в эту дату
        let alreadyCompleted = completedTrackers.contains {
            $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        
        guard !alreadyCompleted else { return }
        
        completedTrackers.append(TrackerRecord(id: id, date: date))
        print("Трекер \(id) выполнен \(date)")
    }
    
    // Обновление состояние трекера на "не выполнено" в нужный день
    func uncompleteTracker(id: UUID, date: Date) {
        for (categoryIndex, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == id }) {
                let tracker = category.trackers[trackerIndex]
                let updatedTracker = tracker.withCompletedState(false)
                
                var updatedTrackers = category.trackers
                updatedTrackers[trackerIndex] = updatedTracker
                
                categories[categoryIndex] = category.withTrackers(updatedTrackers)
                completedTrackers.removeAll { $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: date) }
                break
            }
        }
    }
    // Определение дня недели для указанной даты и фильтрация трекеров
    func getTrackers(for date: Date, searchText: String? = nil) -> [TrackerCategory] {
        let weekday = Calendar.current.component(.weekday, from: date)
        guard let currentWeekday = Weekday(rawValue: weekday) else { return [] }
        print("Фильтрация для дня: \(currentWeekday). Все категории:", categories.map { "\($0.title): \($0.trackers.count)" })
        let isToday = Calendar.current.isDateInToday(date)
        
        let filtered = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesSearch = searchText == nil || tracker.title.lowercased().contains(searchText!.lowercased())
                
                // Для нерегулярных трекеров показываем только если это сегодня
                if !tracker.isRegular {
                    return isToday && matchesSearch
                }
                
                // Для регулярных - по расписанию
                let matchesSchedule = tracker.schedule?.contains(currentWeekday) ?? true
                print("Трекер '\(tracker.title)': schedule=\(tracker.schedule?.map { $0.rawValue } ?? []), matches=\(matchesSchedule)")
                return matchesSearch && matchesSchedule
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        print("После фильтрации: \(filtered.count) категорий")
        return filtered
        
    }
}
