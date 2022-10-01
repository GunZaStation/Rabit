import Foundation

struct Goal {
    
    let title: String
    let subtitle: String
    var progress: Int
    let period: Period
    let certTime: CertifiableTime
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
        self.period = Period(start: entity.startDate, end: entity.endDate)
        self.certTime = CertifiableTime(
                            start: entity.startCertTime,
                            end: entity.endCertTime,
                            days: Days(entity.certDays)
                        )
    }
    
    func toEntity<T: GoalEntity>() -> T {
        .init(
            title: title,
            subtitle: subtitle,
            progress: progress,
            target: target,
            category: category,
            period: period,
            certTime: certTime
        )
    }
}
