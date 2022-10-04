import Foundation

struct DateConverter {
    static private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .autoupdatingCurrent
        return dateFormatter
    }()

    static func convertToDayString(date: Date) -> String {
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: date)
    }

    static func convertToPeriodString(date: Date) -> String {
        dateFormatter.dateFormat = "y-MM-dd"
        return dateFormatter.string(from: date)
    }

    static func convertToYearAndMonthString(date: Date) -> String {
        dateFormatter.dateFormat = "yyyy년 MM월"
        return dateFormatter.string(from: date)
    }
}
