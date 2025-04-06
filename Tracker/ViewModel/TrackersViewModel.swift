import Foundation

final class TrackersViewModel {
    private let trackersService: TrackersServiceProtocol
     private(set) var trackers: [TrackerCategory] = []
     var onDataUpdated: (() -> Void)?
     var currentDate = Date() 
    
    init(trackersService: TrackersServiceProtocol) {
        self.trackersService = trackersService
    }
    
    func loadTrackers(for date: Date, searchText: String? = nil) {
        currentDate = date
        let loadedTrackers = trackersService.getTrackers(for: date, searchText: searchText)
        
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
        
        print("Загружено \(trackers.count) категорий на \(date)")
        onDataUpdated?()
    }
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        print("Добавляем трекер:", tracker)
        trackersService.addTracker(tracker, to: categoryTitle)
        loadTrackers(for: currentDate)
    }
    
    func getCompletedDaysCount(for trackerId: UUID) -> Int {
        let completed = trackersService.completedTrackers.filter { $0.id == trackerId }
        print("Трекер \(trackerId): выполнен \(completed.count) раз(а), все даты: \(completed.map { $0.date })")
        return completed.count
    }
    
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

    func uncompleteTracker(id: UUID, date: Date) {
        let today = Calendar.current.startOfDay(for: date)
        print("Отменяем выполнение трекера \(id) на дату \(today)")
        
        trackersService.uncompleteTracker(id: id, date: today)
        loadTrackers(for: currentDate)
    }
    
      
      func isTrackerCompletedToday(_ trackerId: UUID) -> Bool {
          let today = Calendar.current.startOfDay(for: currentDate)
          return trackersService.completedTrackers.contains {
              $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: today)
          }
      }
}
