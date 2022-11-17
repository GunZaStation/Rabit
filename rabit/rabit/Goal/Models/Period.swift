import Foundation

struct Period: Equatable {
    
    let start: Date
    let end: Date
    
    init() {
        let calendar = Calendar(identifier: .gregorian)
        let currDate = calendar.dateComponents([.year, .month, .day], from: Date())
        let today = calendar.date(from: currDate) ?? Date()
        self.start = today
        self.end = today
    }
        
    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}

extension Period: CustomStringConvertible {
    var description: String {
        let start = DateConverter.convertToPeriodString(date: start)
        let end = DateConverter.convertToPeriodString(date: end)

        return "\(start) ~ \(end)"
    }
}
