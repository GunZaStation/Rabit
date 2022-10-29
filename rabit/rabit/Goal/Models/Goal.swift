import Foundation

@propertyWrapper
struct DayCountable {
    
    private var dayCount: Int = .zero
    var wrappedValue: Int {
        return dayCount
    }
    
    init(period: Period, days: Set<Day>) {
        self.dayCount = countAllDays(period: period, days: days)
    }
    
    private func countAllDays(period: Period, days: Set<Day>) -> Int {
        var count = 0
        for date in stride(from: period.start, to: period.end, by: 60*60*24) {
            guard let day = Day(rawValue: Calendar.current.component(.weekday, from: date) - 1) else {
                continue
            }
            if days.contains(day) { count += 1 }
        }
        return count
    }
}

struct Goal {
    
    let title: String
    let subtitle: String
    var progress: Int
    let period: Period
    let certTime: CertifiableTime
    let category: String
    var target: Int
    let creationDate: Date
    
    init(title: String, subtitle: String, progress: Int = .zero, period: Period, certTime: CertifiableTime, category: String, creationDate: Date = Date()) {
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.period = period
        self.certTime = certTime
        self.category = category
        self.creationDate = creationDate
        
        @DayCountable(period: period, days: certTime.days.selectedValues)
        var target
        
        self.target = target
    }
}

extension Goal: Persistable {
    
    init(entity: GoalEntity) {
        self.title = entity.title
        self.subtitle = entity.subtitle
        self.progress = entity.progress
        self.target = entity.target
        self.category = entity.category
        self.period = Period(start: entity.startDate, end: entity.endDate)
        self.certTime = CertifiableTime(
                            start: entity.startCertTime,
                            end: entity.endCertTime,
                            days: Days(entity.certDays)
                        )
        self.creationDate = entity.creationDate
    }
    
    func toEntity<T: GoalEntity>() -> T {
        .init(
            title: title,
            subtitle: subtitle,
            progress: progress,
            target: target,
            category: category,
            period: period,
            certTime: certTime,
            creationDate: creationDate
        )
    }
}
