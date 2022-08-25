import Foundation
import RealmSwift

@objcMembers
final class PhotoEntity: Object {
    dynamic var imageData: Data = Data()
    dynamic var date: Date = Date()
    dynamic var color: String = ""

    convenience init(
        imageData: Data,
        date: Date,
        color: String
    ) {
        self.init()
        self.imageData = imageData
        self.date = date
        self.color = color
    }
}
