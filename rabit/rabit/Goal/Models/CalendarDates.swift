import Foundation
import Differentiator

struct CalendarDates {
    typealias Item = CalendarDate
    var items: [Item]

    init(items: [Item]) {
        self.items = items
    }

    mutating func resetDaysSelectedState() {
        items = items.map {
            var temp = $0
            temp.isSelected = false
            return temp
        }
    }
}

extension CalendarDates: SectionModelType {
    init(original: CalendarDates, items: [Item]) {
        self = original
        self.items = items
    }
}
