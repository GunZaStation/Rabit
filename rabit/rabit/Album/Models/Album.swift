import Foundation
import Differentiator

struct Album: Equatable {
    typealias Item = Photo
    var categoryTitle: String
    var items: [Item]

    init(categoryTitle: String, items: [Item]) {
        self.categoryTitle = categoryTitle
        self.items = items
    }
}

extension Album: AnimatableSectionModelType {
    typealias Identity = String

    init(original: Album, items: [Item]) {
        self = original
        self.items = items
    }

    var identity: String {
        return self.categoryTitle
    }
}
