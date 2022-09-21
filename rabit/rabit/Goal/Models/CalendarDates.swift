import Foundation
import Differentiator

struct CalendarDates {
    typealias Item = CalendarDate
    var items: [Item]

    init(items: [Item]) {
        self.items = items
    }
}

extension CalendarDates: SectionModelType {
    init(original: CalendarDates, items: [Item]) {
        self = original
        self.items = items
    }
}
