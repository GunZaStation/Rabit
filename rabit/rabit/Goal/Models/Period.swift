import Foundation

struct Period: CustomStringConvertible {
    
    let start: Date
    let end: Date
    
    var description: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: start)) ~ \(formatter.string(from: end))"
    }
        
    init(start: Date = Date(), end: Date = Date()) {
        self.start = start
        self.end = end
    }
}
