import Foundation

struct TimeComponent {
    
    let hour: Int
    let minute: Int
    let seconds: Int
    
    var formattedString: String {
        let isMorning = (0...12) ~= hour ? true : false
        let ampm = isMorning ? "AM" : "PM"
        let hour = isMorning ? hour : hour-12
        return "\(ampm) \(hour)시 \(minute)분"
    }
}

extension TimeComponent {
    
    func toDateComponents() -> DateComponents {
        return DateComponents(hour: hour, minute: minute)
    }
}
