import Foundation
import RealmSwift

class CategoryEntity: Object {
    
    @Persisted var title: String = ""
    @Persisted var createdDate: Date

    convenience init(title: String, createdDate: Date) {
        self.init()

        self.title = title
        self.createdDate = createdDate
    }
    
    override static func primaryKey() -> String? {
        return "title"
    }
}
