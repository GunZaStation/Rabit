import Foundation
import Differentiator

struct Album {
    typealias Item = Photo
    var categoryTitle: String
    var items: [Item]

    init(categoryTitle: String, items: [Item]) {
        self.categoryTitle = categoryTitle
        self.items = items
    }
}

extension Album: SectionModelType {
    init(original: Album, items: [Item]) {
        self = original
        self.items = items
    }
}
