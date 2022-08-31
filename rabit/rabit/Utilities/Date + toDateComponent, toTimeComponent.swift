import Foundation

extension Date {
    
    func toDateComponent() -> DateComponent {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        
        return DateComponent(
            year: components.year ?? -1,
            month: components.month ?? -1,
            day: components.day ?? -1
        )
    }
    
    func toTimeComponent() -> TimeComponent {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self)
        
        return TimeComponent(
            hour: components.hour ?? -1,
            minute: components.minute ?? -1,
            seconds: components.second ?? -1
        )
    }
}
