import RealmSwift

final class GoalEntity: Object {
    
    @Persisted var title: String = ""
    @Persisted var subtitle: String = ""
    @Persisted var progress: Int = 0
    @Persisted var target: Int = 0
    @Persisted var category: String = ""
    @Persisted var startCertTime: Int = 0
    @Persisted var endCertTime: Int = 0
    @Persisted var certDays: List<Int> = List()
    
    convenience init(
        title: String,
        subtitle: String,
        progress: Int,
        target: Int,
        category: String,
        certTime: CertifiableTime) {
        self.init()
        
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.target = target
        self.category = category
        self.startCertTime = certTime.start.toSeconds()
        self.endCertTime = certTime.end.toSeconds()
        self.certDays.append(objectsIn: certTime.days.toIntArray())
    }
}

extension Days {
    
    init(_ list: List<Int>) {
        self.set = Set(list.compactMap { Day(rawValue: $0) })
    }
    
    func toIntArray() -> [Int] {
        return Array(self.set).map { $0.rawValue }
    }
}
