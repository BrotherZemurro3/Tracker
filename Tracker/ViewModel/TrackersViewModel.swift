import Foundation

// Данный класс работает с TrackersService и получает данные и подготавливает их для отображения.
// Так же он реагирует на пользовательские действия (например, фильтрация, отметка выполнения)

final class TrackersViewModel {
    // MARK: - Properties
    private let trackersService: TrackersServiceProtocol
    private(set) var trackers: [TrackerCategory] = []
    
    var onDataUpdated: (() -> Void)? // Колбэк для обновления UI
    
    // MARK: - Init
    init(trackersService: TrackersServiceProtocol) {
        self.trackersService = trackersService
    }
    
    // MARK: - Public Methods
    
    func loadTrackers(for date: Date, searchText: String? = nil) {
        trackers = trackersService.getTrackers(for: date, searchText: searchText)
        onDataUpdated?() // Сообщаем UI, что данные обновились
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let index = trackers.firstIndex(where: { $0.title == categoryTitle }) {
            trackers[index].trackers.append(tracker)
        } else {
            trackers.append(TrackerCategory(title: categoryTitle, trackers: [tracker]))
        }
        
        print("Добавлен трекер: \(tracker.title), всего категорий: \(trackers.count)")
        onDataUpdated?()
    }
    
    func completeTracker(id: UUID, date: Date) {
        trackersService.completeTracker(id: id, date: date)
        loadTrackers(for: date) // Перезагружаем данные
    }
    
    func uncompleteTracker(id: UUID, date: Date) {
        trackersService.uncompleteTracker(id: id, date: date)
        loadTrackers(for: date) // Перезагружаем данные
    }
}



