import Foundation

struct CertifiableTime: CustomStringConvertible {
    
    // 지정한 요일에, 시작~끝 시간 동안만 인증이 가능
    let start: TimeComponent
    let end: TimeComponent
    let days: Days
    
    var description: String {
        return "\(days) \(start.formattedString) ~ \(end.formattedString)"
    }
    
    init() {
        let currDate = Date()
        self.start = currDate.toTimeComponent()
        self.end = currDate.toTimeComponent()
        self.days = Days()
    }
    
    init(start: Date, end: Date) {
        self.start = start.toTimeComponent()
        self.end = end.toTimeComponent()
        self.days = Days()
    }
    
    init(start: Int, end: Int, days: Days) {
        self.start = TimeComponent(rawValue: start)
        self.end = TimeComponent(rawValue: end)
        self.days = days
    }
}
