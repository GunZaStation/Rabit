import Foundation

extension Date {
    
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
