import Foundation

struct Goal {
    
    let title: String
    let subtitle: String
    var progress: Int
    let period: Period
    let certTime: CertifiableTime
    let category: String
    
    var target: Int {
        var count = 0
        let days = certTime.days.selectedValues
        for date in stride(from: period.start, to: period.end, by: 60*60*24) {
            guard let day = Day(rawValue: Calendar.current.component(.weekday, from: date) - 1) else {
                continue
            }
            if days.contains(day) { count += 1 }
        }
        return count
    }
}

extension Goal: Persistable {
    
    init(entity: GoalEntity) {
        self.title = entity.title
        self.subtitle = entity.subtitle
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
