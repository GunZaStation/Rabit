import Foundation
import RealmSwift

final class PhotoEntity: Object {
    @Persisted var uuid: UUID = UUID()
    @Persisted var categoryTitle: String = ""
    @Persisted var goalTitle: String = ""
    @Persisted var imageData: Data = Data()
    @Persisted var date: Date = Date()
    @Persisted var color: String = ""

    convenience init(
        uuid: UUID,
        categoryTitle: String,
        goalTitle: String,
        imageData: Data,
        date: Date,
        color: String
    ) {
        self.init()
        self.uuid = uuid
        self.categoryTitle = categoryTitle
        self.goalTitle = goalTitle
        self.imageData = imageData
        self.date = date
        self.color = color
    }

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
