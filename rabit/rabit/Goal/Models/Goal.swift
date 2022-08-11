import Foundation
import Differentiator

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
