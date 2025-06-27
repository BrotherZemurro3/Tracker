import Foundation



final class DateFormatterHelper {
    static let shared = DateFormatterHelper()
    private init() {}
    
    private lazy var shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func formatDateToString(_ date: Date) -> String {
        return shortDateFormatter.string(from: date)
    }
}
