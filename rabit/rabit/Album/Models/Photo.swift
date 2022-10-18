import Foundation

struct Photo: Equatable {
    let uuid: UUID
    let categoryTitle: String
    let goalTitle: String
    let imageData: Data
    let date: Date
    var color: String
    var style: Style

    init(
        uuid: UUID = UUID(),
        categoryTitle: String,
        goalTitle: String,
        imageData: Data,
        date: Date,
        color: String,
        style: Style
    ) {
        self.uuid = uuid
        self.categoryTitle = categoryTitle
        self.goalTitle = goalTitle
        self.imageData = imageData
        self.date = date
        self.color = color
        self.style = style
    }

    init() {
        self.init(
            categoryTitle: "",
            goalTitle: "",
            imageData: Data(),
            date: Date(),
            color: "",
            style: .none
        )
    }
}

extension Photo: Persistable {
    init(entity: PhotoEntity) {
        self.init(
            uuid: entity.uuid,
            categoryTitle: entity.categoryTitle,
            goalTitle: entity.goalTitle,
            imageData: entity.imageData,
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
            imageData: self.imageData,
            date: self.date,
            color: self.color,
            style: self.style.rawValue
        )
    }
}
