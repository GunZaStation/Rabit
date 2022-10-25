import Foundation
import RealmSwift

final class GoalEntity: Object {
    
    @Persisted var uuid: UUID = UUID()
    @Persisted var title: String = ""
    @Persisted var subtitle: String = ""
    @Persisted var progress: Int = 0
    @Persisted var target: Int = 0
    @Persisted var category: String = ""
    @Persisted var startDate: Date = Date()
    @Persisted var endDate: Date = Date()
    @Persisted var startCertTime: Int = 0
    @Persisted var endCertTime: Int = 0
    @Persisted var certDays: List<Int> = List()
    
    convenience init(
        title: String,
        subtitle: String,
        progress: Int,
        target: Int,
        category: String,
        period: Period,
        certTime: CertifiableTime) {
        self.init()
        
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.target = target
        self.category = category
        self.startDate = period.start
        self.endDate = period.end
        self.startCertTime = certTime.start.toSeconds()
        self.endCertTime = certTime.end.toSeconds()
        self.certDays.append(objectsIn: certTime.days.toIntArray())
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

extension Days {
    
    init(_ list: List<Int>) {
        self.selectedValues = Set(list.compactMap { Day(rawValue: $0) })
    }
    
    func toIntArray() -> [Int] {
        return self.selectedValues.map(\.rawValue)
    }
}
