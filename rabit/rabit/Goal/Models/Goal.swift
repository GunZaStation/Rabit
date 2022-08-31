import Foundation

struct Goal {
    
    let title: String
    let subtitle: String
    var progress: Int
//    let period: Period
    let target: Int
    let category: String
}

extension Goal: Persistable {
    
    init(entity: GoalEntity) {
        self.title = entity.title
        self.subtitle = entity.subtitle
        self.target = entity.target
        self.progress = entity.progress
        self.category = entity.category
//        self.period = Period()
    }
    
    func toEntity<T: GoalEntity>() -> T {
        .init(
            title: title,
            subtitle: subtitle,
            progress: progress,
            target: target,
            category: category
        )
    }
}
