import Foundation
import RealmSwift

final class PhotoEntity: Object {
    @Persisted var uuid: UUID = UUID()
    @Persisted var categoryTitle: String = ""
    @Persisted var goalTitle: String = ""
    @Persisted var imageName: String = ""
    @Persisted var date: Date = Date()
    @Persisted var color: String = ""
    @Persisted var style: String = ""

    convenience init(
        uuid: UUID,
        categoryTitle: String,
        goalTitle: String,
        imageName: String,
        date: Date,
        color: String,
        style: String
    ) {
        self.init()
        self.uuid = uuid
        self.categoryTitle = categoryTitle
        self.goalTitle = goalTitle
        self.imageName = imageName
        self.date = date
        self.color = color
        self.style = style
    }

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
