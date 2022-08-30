import Foundation

struct Period: CustomStringConvertible {
    
    let start: DateComponent
    let end: DateComponent
    
    var description: String {
        return "\(start.formattedString) ~ \(end.formattedString)"
    }
        
    init(start: Date, end: Date) {
        self.start = start.toDateComponent()
        self.end = end.toDateComponent()
    }
}
