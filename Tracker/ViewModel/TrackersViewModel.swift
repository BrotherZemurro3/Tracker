import Foundation

final class TrackersViewModel {
    private let trackersService: TrackersServiceProtocol
     private(set) var trackers: [TrackerCategory] = []
     var onDataUpdated: (() -> Void)?
     private var currentDate = Date() 
    
    init(trackersService: TrackersServiceProtocol) {
        self.trackersService = trackersService
    }
    
    func loadTrackers(for date: Date, searchText: String? = nil) {
        currentDate = date
        let loadedTrackers = trackersService.getTrackers(for: date, searchText: searchText)
        self.trackers = loadedTrackers
        print("Загружено \(trackers.count) категорий для \(date)")
        onDataUpdated?()
    }
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        print("Добавляем трекер:", tracker)
        trackersService.addTracker(tracker, to: categoryTitle)
        loadTrackers(for: currentDate)
    }
    
    func getCompletedDaysCount(for trackerId: UUID) -> Int {
        return trackersService.completedTrackers.filter { $0.id == trackerId }.count
    }
    
    func completeTracker(id: UUID, date: Date) {
          let today = Calendar.current.startOfDay(for: date)
          
          // Проверяем, не выполнен ли уже трекер сегодня
          let alreadyCompleted = trackersService.completedTrackers.contains {
              $0.id == id && Calendar.current.isDate($0.date, inSameDayAs: today)
          }
          
          guard !alreadyCompleted else { return }
          
          trackersService.completeTracker(id: id, date: today)
          loadTrackers(for: currentDate)
      }
      
      func uncompleteTracker(id: UUID, date: Date) {
          let today = Calendar.current.startOfDay(for: date)
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
