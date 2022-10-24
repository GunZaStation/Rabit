import Foundation
import Differentiator

struct CalendarDates {
    typealias Item = CalendarDate
    var id: UUID
    var items: [Item]

    init(items: [Item]) {
        self.id = UUID()
        self.items = items
    }
}

extension CalendarDates: AnimatableSectionModelType {
    typealias identity = UUID

    init(original: CalendarDates, items: [Item]) {
        self = original
        self.items = items
    }

    var identity: UUID {
        return self.id
    }
}
