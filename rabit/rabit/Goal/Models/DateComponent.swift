import Foundation

struct DateComponent {
    
    let year: Int
    let month: Int
    let day: Int
    
    var formattedString: String {
        return "\(year)-\(month)-\(day)"
    }
}
