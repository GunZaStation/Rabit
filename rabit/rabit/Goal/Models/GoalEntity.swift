import RealmSwift

final class GoalEntity: Object {
    
    @Persisted var title: String = ""
    @Persisted var subtitle: String = ""
    @Persisted var progress: Int = 0
    @Persisted var target: Int = 0
    @Persisted var category: String = ""
    
    convenience init(title: String, subtitle: String, progress: Int, target: Int, category: String) {
        self.init()
        
        self.title = title
        self.subtitle = subtitle
        self.progress = progress
        self.target = target
        self.category = category
    }
}
