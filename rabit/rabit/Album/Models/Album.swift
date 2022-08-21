import Foundation
import Differentiator

struct Album {
    typealias Item = Photo
    var items: [Item]
    var date: Date

    init(date: Date, items: [Item]) {
        self.date = date
        self.items = items
    }
}

extension Album: SectionModelType {
    init(original: Album, items: [Item]) {
        self = original
        self.items = items
    }
}
