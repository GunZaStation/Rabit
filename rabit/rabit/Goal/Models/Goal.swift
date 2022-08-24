import Foundation
import Differentiator
import RealmSwift

@objcMembers
class GoalEntity: Object {
    
    dynamic var category: String = ""

    convenience init(category: String) {
        self.init()

        self.category = category
    }
    
    override static func primaryKey() -> String? {
        return "category"
    }
}

struct Goal {
    
    let category: String
    var items: [GoalDetail]
    
    init(category: String, details: [GoalDetail]) {
        self.category = category
        self.items = details
    }
}

extension Goal: SectionModelType {
    
    init(original: Goal, items: [GoalDetail]) {
        self = original
        self.items = items
    }
}

extension Goal: Persistable {
    
    init(entity: GoalEntity) {
        self.category = entity.category
        self.items = []
    }
    
    func toEntity() -> GoalEntity {
        .init(category: category)
    }
}
