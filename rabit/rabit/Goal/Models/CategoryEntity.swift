import RealmSwift

class CategoryEntity: Object {
    
    @Persisted var title: String = ""

    convenience init(title: String) {
        self.init()

        self.title = title
    }
    
    override static func primaryKey() -> String? {
        return "title"
    }
}
