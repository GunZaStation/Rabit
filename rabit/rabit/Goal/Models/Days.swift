import Foundation

enum Day: Int, CaseIterable, CustomStringConvertible {

    case sun = 0
    case mon = 1
    case tue = 2
    case wed = 3
    case thu = 4
    case fri = 5
    case sat = 6
   
    var description: String {
        switch self {
        case .mon:
            return "월"
        case .tue:
            return "화"
        case .wed:
            return "수"
        case .thu:
            return "목"
        case .fri:
            return "금"
        case .sat:
            return "토"
        case .sun:
            return "일"
        }
    }
}

struct Days: CustomStringConvertible {
    
    let daysSet: Set<Day>
    private let toArray: [Day]
    
    var description: String {
        if isEveryday {
            return "매일"
        } else if isWeekendsOnly {
            return "주말"
        } else if isWeekdaysOnly {
            return "평일"
        } else {
            return self.toArray.description
        }
    }
    
    private var isEveryday: Bool {
        return self.daysSet.count == 7
    }
    
    private var isWeekendsOnly: Bool {
        guard isEveryday == false else { return false }
        guard daysSet.contains(.sun) && daysSet.contains(.sat) else { return false }
        return daysSet.count == 2
    }
    
    private var isWeekdaysOnly: Bool {
        guard isEveryday == false else { return false }
        guard !daysSet.contains(.sun) && !daysSet.contains(.sat) else { return false }
        return daysSet.count == 5 && !isWeekendsOnly
    }
    
    init() {
        self.daysSet = Set(Day.allCases)
        self.toArray = Array(daysSet).sorted { $0.rawValue < $1.rawValue}
    }
    
    init(_ daysSet: Set<Day>) {
        self.daysSet = daysSet
        self.toArray = Array(daysSet).sorted { $0.rawValue < $1.rawValue}
    }
}

extension Array where Element == Day {
    
    var description: String {
        guard self.count >= 1 else { return "" }
        
        if isContinuous {
            return "\(self[0]) ~ \(self[self.count-1])"
        } else {
            return "\(self.reduce("") { "\($0)" + ", " + "\($1)" }.dropFirst())"
        }
    }
    
    var isContinuous: Bool {
        guard self.count >= 3 else { return false }
        
        var curr = self[0].rawValue
        for day in self {
            if curr != day.rawValue { return false }
            curr += 1
        }
    
        return true
    }
}
