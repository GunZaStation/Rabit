import Foundation
import Differentiator

struct Days {
    typealias Item = Day
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

extension Days: SectionModelType {
    init(original: Days, items: [Item]) {
        self = original
        self.items = items
    }
}
