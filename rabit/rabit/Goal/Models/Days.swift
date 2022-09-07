import Foundation
import Differentiator

struct Days {
    typealias Item = Day
    var items: [Item]

    init(items: [Item]) {
        self.items = items
    }
}

extension Days: SectionModelType {
    init(original: Days, items: [Item]) {
        self = original
        self.items = items
    }
}
