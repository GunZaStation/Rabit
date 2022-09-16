import Foundation

struct Period {
    
    let start: Date
    let end: Date
    
    init() {
        let currDate = Date()
        self.start = currDate
        self.end = currDate
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
