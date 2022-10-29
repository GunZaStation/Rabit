import Foundation
import Differentiator

struct Category {
    
    let title: String
    var items: [Goal]
    let creationDate: Date
    
    init(title: String, details: [Goal] = [], creationDate: Date = Date()) {
        self.title = title
        self.items = details
        self.creationDate = creationDate
    }
}

extension Category: SectionModelType {
    
    init(original: Category, items: [Goal]) {
        self = original
        self.items = items
    }
}

extension Category: Persistable {
    
    init(entity: CategoryEntity) {
        self.title = entity.title
        self.creationDate = entity.creationDate
        self.items = []
    }
    
    func toEntity() -> CategoryEntity {
        .init(title: title, creationDate: creationDate)
    }
}
