import Foundation

enum Weekday: Int, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var fullName: String {
        switch self {
        case .monday: return "monday.title".localized
        case .tuesday: return "tuesday.title".localized
        case .wednesday: return "wednesday.title".localized
        case .thursday: return "thursday.title".localized
        case .friday: return "friday.title".localized
        case .saturday: return "saturday.title".localized
        case .sunday: return "sunday.title".localized
        }
    }
    
    var shortName: String {
        switch self {
        case .monday: return "mondayShort.title".localized
        case .tuesday: return "tuesdayShort.title".localized
        case .wednesday: return "wednesdayShort.title".localized
        case .thursday: return "thursdayShort.title".localized
        case .friday: return "fridayShort.title".localized
        case .saturday: return "saturdayShort.title".localized
        case .sunday: return "sundayShort.title".localized
        }
    }
    
    static func fromDate(_ date: Date) -> Weekday {
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        return Weekday(rawValue: weekdayNumber) ?? .monday
    }
    
    
   
    var displayOrder: Int {
        switch self {
        case .monday: return 0
        case .tuesday: return 1
        case .wednesday: return 2
        case .thursday: return 3
        case .friday: return 4
        case .saturday: return 5
        case .sunday: return 6
        }
    }
    
 
    static var displayOrderedCases: [Weekday] {
        return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}
