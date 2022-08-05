import Foundation
import Differentiator

struct Album: SectionModelType {
    typealias Item = [Data?]
    var items: [Item]
    var header: Date

    init(original: Album, items: [[Data?]]) {
        self.items = items
        self.header = Date()
    }

    init(header: Date, items: [[Data?]]) {
        self.header = header
        self.items = items
    }
}
