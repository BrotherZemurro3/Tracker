import Foundation

protocol StatisticServiceProtocol {
    func calculateStatistics(completedTrackers: [TrackerRecord], allTrackers: [Tracker]) -> Statistics
}


struct Statistics {
    let bestPeriod: Int
    let perfectDays: Int
    let trackersCompleted: Int
    let averageValue: Double
    
}



final class StatisticService: StatisticServiceProtocol {
    
    func calculateStatistics(completedTrackers: [TrackerRecord], allTrackers: [Tracker]) -> Statistics {
        
        // Лучший период - макс дней подряд с выполняемыми трекерами
        
        let bestPeriod = calculateBestPeriod(records: completedTrackers)
        
        let perfectDays = calculatePerfectDays(completedTrackers: completedTrackers, allTrackers: allTrackers)
        
        let trackersCompleted = completedTrackers.count
        
        let averageValue = calculateAverageValue(records: completedTrackers)
        
        return Statistics(bestPeriod: bestPeriod, perfectDays: perfectDays, trackersCompleted: trackersCompleted, averageValue: averageValue)
    }
    
    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let dates = records.map { $0.date.startOfDay }.sorted()
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<dates.count {
            if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: dates[i]) {
                if Calendar.current.isDate(dates[i-1], inSameDayAs: previousDay) {
                    currentStreak += 1
                    maxStreak = max(maxStreak, currentStreak)
                } else if !Calendar.current.isDate(dates[i-1], inSameDayAs: dates[i]) {
                    currentStreak = 1
                }
            }
        }
        
        return maxStreak
    }

    private func calculatePerfectDays(completedTrackers: [TrackerRecord], allTrackers: [Tracker]) -> Int {
        guard !allTrackers.isEmpty else {return 0}
        
        let completedDates = Dictionary(grouping: completedTrackers, by: {$0.date.startOfDay})
        
        let allTrackersByDay = Dictionary(grouping: allTrackers, by: { $0.creationDate.startOfDay})
        
        
        var perfectDays = 0
        
        for (date, completedTrackersOnDay) in completedDates {
            if let allTrackersOnDay = allTrackersByDay[date] {
                let uniqueCompletedCount = Set(completedTrackersOnDay.map {$0.id}).count
                perfectDays += 1
            }
        }
        return perfectDays
    }
    
    private func calculateAverageValue(records: [TrackerRecord]) -> Double {
        
        guard !records.isEmpty else {return 0}
        
        let daysCount = Set(records.map{$0.date.startOfDay}).count
        return Double(records.count) / Double(daysCount)
    }
    
    
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
