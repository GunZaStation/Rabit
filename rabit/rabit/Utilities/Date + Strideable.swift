import Foundation

extension Date: Strideable {
    
    public func distance(to endDate: Date) -> TimeInterval {
        return endDate.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by interval: TimeInterval) -> Date {
        return self + interval
    }
}
