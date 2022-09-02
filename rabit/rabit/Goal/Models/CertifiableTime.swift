import Foundation

enum WeekDay: Int {
    
    case mon = 1
    case tue = 2
    case wed = 3
    case thu = 4
    case fri = 5
    case sat = 6
    case sun = 0
}

struct CertifiableTime: CustomStringConvertible {
    
    // 지정한 요일에, 시작~끝 시간 동안만 인증이 가능
    let start: TimeComponent
    let end: TimeComponent
    let weekdays: [WeekDay] = []
    
    var description: String {
        return "\(start.formattedString) ~ \(end.formattedString)"
    }
    
    init(start: Date, end: Date) {
        self.start = start.toTimeComponent()
        self.end = end.toTimeComponent()
    }
}
