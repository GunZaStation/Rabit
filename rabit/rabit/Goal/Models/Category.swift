import Foundation
import Differentiator

struct Category {
    
    let title: String
    var items: [Goal]
    let createdDate: Date
    
    init(title: String, details: [Goal] = [], createdDate: Date = Date()) {
        self.title = title
        self.items = details
        self.createdDate = createdDate
    }
}

extension Category: AnimatableSectionModelType {
    typealias Identity = String
    
    init(original: Category, items: [Goal]) {
        self = original
        self.items = items
    }
    
    var identity: String {
        return title
    }
}

extension Category: Persistable {
    
    init(entity: CategoryEntity) {
        self.title = entity.title
        self.createdDate = entity.createdDate
        self.items = []
    }
    
    func toEntity() -> CategoryEntity {
        .init(title: title, createdDate: createdDate)
    }
}
