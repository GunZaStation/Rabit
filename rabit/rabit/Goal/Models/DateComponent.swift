import Foundation

struct DateComponent {
    
    let year: Int
    let month: Int
    let day: Int
    
    var formattedString: String {
        let month = month >= 10 ? "\(month)" : "0\(month)"
        let day = day >= 10 ? "\(day)" : "0\(day)"
        return "\(year)-\(month)-\(day)"
    }
}

extension DateComponent {
    
    func toDateComponents() -> DateComponents {
        return DateComponents(year: year, month: month, day: day)
    }
}
