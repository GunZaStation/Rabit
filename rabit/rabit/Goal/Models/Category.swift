import Foundation
import Differentiator

struct Category {
    
    let title: String
    var items: [Goal]
    
    init(title: String, details: [Goal] = []) {
        self.title = title
        self.items = details
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
        self.items = []
    }
    
    func toEntity() -> CategoryEntity {
        .init(title: title)
    }
}
