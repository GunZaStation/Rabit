import Foundation
import Differentiator

@propertyWrapper
struct DayCountable {
    
    private var dayCount: Int = .zero
    var wrappedValue: Int {
        return dayCount
    }
    
    init(period: Period, certTime: CertifiableTime, createdDate: Date) {
        self.dayCount = countAllDays(period: period, certTime: certTime, createdDate: createdDate)
    }
    
    private func countAllDays(period: Period, certTime: CertifiableTime, createdDate: Date) -> Int {
        let days = certTime.days.selectedValues
        var count = 0
        for date in stride(from: period.start, through: period.end, by: 60*60*24) {
            guard let day = Day(
                rawValue: Calendar.current.component(.weekday, from: date) - 1
            )  else {
                continue
            }
            if days.contains(day) { count += 1 }
        }
        
        let alarmEndTimeInSeconds = certTime.end.hour * 60 * 60 + certTime.end.minute * 60 + certTime.end.seconds
        let firstAlarmEndTimeInDate = Date(
            timeInterval: TimeInterval(alarmEndTimeInSeconds),
            since: period.start
        )
        
        if createdDate > firstAlarmEndTimeInDate  {
            count -= 1
        }
        
        return count
    }
}

struct Goal: Equatable {
    
    let uuid: UUID
    let title: String
    let subtitle: String
    var progress: Int
    let period: Period
    let certTime: CertifiableTime
    let category: String
    var target: Int
    let createdDate: Date
    
    init(
        uuid: UUID = UUID(),
        title: String,
        subtitle: String,
        progress: Int = .zero,
        period: Period,
        certTime: CertifiableTime,
        category: String,
        createdDate: Date = Date()
    ) {
        self.uuid = uuid
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.period = period
        self.certTime = certTime
        self.category = category
        self.createdDate = createdDate
        
        @DayCountable(period: period, certTime: certTime, createdDate: createdDate)
        var target
        
        self.target = target
    }
}

extension Goal: IdentifiableType {
    typealias identifier = UUID
    
    var identity: UUID {
        return uuid
    }
}

extension Goal: Persistable {
    
    init(entity: GoalEntity) {
        self.uuid = entity.uuid
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
        self.createdDate = entity.createdDate
    }
    
    func toEntity<T: GoalEntity>() -> T {
        .init(
            uuid: uuid,
            title: title,
            subtitle: subtitle,
            progress: progress,
            target: target,
            category: category,
            period: period,
            certTime: certTime,
            createdDate: createdDate
        )
    }
}
