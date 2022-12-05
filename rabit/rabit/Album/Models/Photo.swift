import Foundation
import Differentiator

struct Photo: Equatable {
    let uuid: UUID
    let categoryTitle: String
    let goalTitle: String
    let imageName: String
    let date: Date
    var color: String
    var style: Style
    var imageData: Data?
    
    init(
        uuid: UUID = UUID(),
        categoryTitle: String,
        goalTitle: String,
        imageName: String,
        date: Date,
        color: String,
        style: Style,
        imageData: Data? = nil
    ) {
        self.uuid = uuid
        self.categoryTitle = categoryTitle
        self.goalTitle = goalTitle
        self.imageName = imageName
        self.date = date
        self.color = color
        self.style = style
        self.imageData = imageData
    }

    // Initializer for newly taken photo
    init(
        categoryTitle: String,
        goalTitle: String,
        imageName: String,
        imageData: Data?
    ) {
        self.init(
            categoryTitle: categoryTitle,
            goalTitle: goalTitle,
            imageName: imageName,
            date: Date(),
            color: "#FFFFFF",
            style: .none,
            imageData: imageData
        )
    }

    init() {
        self.init(
            categoryTitle: "",
            goalTitle: "",
            imageName: "",
            date: Date(),
            color: "",
            style: .none
        )
    }
}

extension Photo: IdentifiableType {
    typealias identifier = UUID

    var identity: UUID {
        return self.uuid
    }
}

extension Photo: Persistable {
    init(entity: PhotoEntity) {
        self.init(
            uuid: entity.uuid,
            categoryTitle: entity.categoryTitle,
            goalTitle: entity.goalTitle,
            imageName: entity.imageName,
            date: entity.date,
            color: entity.color,
            style: Style(entity.style)
        )
    }
    
    func toEntity<T: PhotoEntity>() -> T {
        return T(
            uuid: self.uuid,
            categoryTitle: self.categoryTitle,
            goalTitle: self.goalTitle,
            imageName: self.imageName,
            date: self.date,
            color: self.color,
            style: self.style.rawValue
        )
    }
}
