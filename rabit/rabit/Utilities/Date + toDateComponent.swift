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
}
