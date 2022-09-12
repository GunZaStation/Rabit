import Foundation

struct Period: Equatable {
    
    let start: Date
    let end: Date
    
    init() {
        let currDate = Date()
        self.start = currDate
        self.end = currDate
    }
        
    init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}
