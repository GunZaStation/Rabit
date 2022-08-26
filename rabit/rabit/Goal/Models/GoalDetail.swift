import Foundation
import RealmSwift

final class GoalDetailEntity: Object {
    
    @Persisted var title: String = ""
    @Persisted var subtitle: String = ""
    @Persisted var progress: Int = 0
    @Persisted var target: Int = 0
    @Persisted var category: String = ""
    
    convenience init(title: String, subtitle: String, progress: Int, target: Int, category: String) {
        self.init()
        
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.target = target
        self.category = category
    }
}

struct GoalDetail {
    
    let title: String
    let subtitle: String
    var progress: Int
    let target: Int
    let category: String
}

extension GoalDetail: Persistable {
    
    init(entity: GoalDetailEntity) {
        self.title = entity.title
        self.subtitle = entity.subtitle
        self.target = entity.target
        self.progress = entity.progress
        self.category = entity.category
    }
    
    func toEntity<T: GoalDetailEntity>() -> T {
        .init(
            title: title,
            subtitle: subtitle,
            progress: progress,
            target: target,
            category: category
        )
    }
}
