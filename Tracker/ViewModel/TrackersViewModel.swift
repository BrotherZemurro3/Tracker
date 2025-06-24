import Foundation

final class TrackersViewModel {
    private let trackersService: TrackersServiceProtocol
    private(set) var trackers: [TrackerCategory] = []
    private var selectedFilter: TrackerFilter = .all
    
    // Замыкание для обновления UI при изменении данных
    var onDataUpdated: (() -> Void)?
    // Дата
    var currentDate = Date()
    
    init(trackersService: TrackersServiceProtocol) {
        self.trackersService = trackersService
        
        if let service = trackersService as? TrackersService {
            service.trackerStore.onChange = { [weak self] in
                self?.loadTrackers(for: self?.currentDate ?? Date())
            }
        }
    }
    
    // Установка фильтра
    func setFilter(_ filter: TrackerFilter) {
        AnalyticsService.shared.report(event: "filter", screen: "Main", item: filter.rawValue)
        selectedFilter = filter
        loadTrackers(for: currentDate)
    }
    
    // Загружает трекеры для указанной даты с учетом фильтра и поиска
    func loadTrackers(for date: Date, searchText: String? = nil) {
        currentDate = date
        var loadedTrackers = trackersService.getTrackers(for: date, searchText: searchText)
        
        // Применяем фильтр
        loadedTrackers = loadedTrackers.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                switch selectedFilter {
                case .all:
                    return true
                case .today:
                    let creationDay = Calendar.current.startOfDay(for: tracker.creationDate)
                    let currentDay = Calendar.current.startOfDay(for: date)
                    return Calendar.current.isDate(date, inSameDayAs: tracker.creationDate) || (tracker.isRegular && currentDay >= creationDay)
                case .completed:
                    return trackersService.completedTrackers.contains {
                        $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
                    }
                case .notCompleted:
                    return !trackersService.completedTrackers.contains {
                        $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
                    }
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        // Обновляем статус выполнения трекеров
        trackers = loadedTrackers.map { category in
            let updatedTrackers = category.trackers.map { tracker in
                let isCompleted = trackersService.completedTrackers.contains {
                    $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: date)
                }
                return tracker.withCompletedState(isCompleted)
            }
            return TrackerCategory(title: category.title, trackers: updatedTrackers)
        }
        
        print("Загружено \(trackers.count) категорий на \(date) с фильтром \(selectedFilter.rawValue)")
        onDataUpdated?()
    }
    
    // Добавление трекера в указанную категорию
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        print("Добавляем трекер:", tracker)
        trackersService.addTracker(tracker, to: categoryTitle)
        loadTrackers(for: currentDate)
    }
    
    func deleteTracker(id: UUID) {
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "delete")
        print("Удаляем трекер с ID: \(id)")
        trackersService.deleteTracker(id)
        loadTrackers(for: currentDate)
    }
    
    func didUpdateTracker(_ tracker: Tracker, in categoryTitle: String, oldCategoryTitle: String?) {
         print("Updating tracker:", tracker.title)
         trackersService.updateTracker(tracker, in: categoryTitle, oldCategoryTitle: oldCategoryTitle)
         loadTrackers(for: currentDate)
     }
    
    func pinTracker(id: UUID) {
        print("Закрепляем трекер с ID: \(id)")
        trackersService.pinTracker(id)
        loadTrackers(for: currentDate)
    }
    
    func unpinTracker(id: UUID) {
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "unpin")
        print("Открепляем трекер с ID: \(id)")
        trackersService.unpinTracker(id)
        loadTrackers(for: currentDate)
    }
    
    // Возвращение количество выполненных дней для трекера
    func getCompletedDaysCount(for trackerId: UUID) -> Int {
        let completed = trackersService.completedTrackers.filter { $0.id == trackerId }
        print("Трекер \(trackerId): выполнен \(completed.count) раз(а), все даты: \(completed.map { $0.date })")
        return completed.count
    }
    
    // Отметка трекера как выполненного
    func completeTracker(id: UUID, date: Date) {
        let today = Calendar.current.startOfDay(for: date)
        
        let alreadyCompleted = trackersService.completedTrackers.contains {
            $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: today)
        }
        
        guard !alreadyCompleted else {
            print("Трекер уже выполнен сегодня, пропускаем \(id)")
            return
        }
        
        trackersService.completeTracker(id: id, date: today)
        print("Трекер \(id) выполнен на дату \(today)")
        loadTrackers(for: currentDate)
    }
    
    // Отмена выполнения трекера
    func uncompleteTracker(id: UUID, date: Date) {
        let today = Calendar.current.startOfDay(for: date)
        print("Отменяем выполнение трекера \(id) на дату \(today)")
        
        trackersService.uncompleteTracker(id: id, date: today)
        loadTrackers(for: currentDate)
    }
    
    // Проверка: выполнен ли трекер сегодня
    func isTrackerCompletedToday(_ trackerId: UUID) -> Bool {
        let today = Calendar.current.startOfDay(for: currentDate)
        return trackersService.completedTrackers.contains {
            $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
}
