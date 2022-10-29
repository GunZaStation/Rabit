import Foundation
import RealmSwift

class CategoryEntity: Object {
    
    @Persisted var title: String = ""
    @Persisted var creationDate: Date

    convenience init(title: String, creationDate: Date) {
        self.init()

        self.title = title
        self.creationDate = creationDate
    }
    
    override static func primaryKey() -> String? {
        return "title"
    }
}
