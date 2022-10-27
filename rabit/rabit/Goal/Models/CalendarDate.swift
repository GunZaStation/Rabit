import Foundation
import Differentiator

struct CalendarDate: Equatable {
    let date: Date
    let number: String
    var isWithinDisplayedMonth: Bool
    var isBeforeToday: Bool
}

extension CalendarDate: IdentifiableType {
    typealias identifier = Date

    var identity: Date {
        return self.date
    }
}
