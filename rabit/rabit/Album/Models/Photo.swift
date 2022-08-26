import Foundation

struct Photo {
    let categoryTitle: String
    let goalTitle: String
    let imageData: Data
    let date: Date
    var color: String

    init(
        categoryTitle: String,
        goalTitle: String,
        imageData: Data,
        date: Date,
        color: String
    ) {
        self.categoryTitle = categoryTitle
        self.goalTitle = goalTitle
        self.imageData = imageData
        self.date = date
        self.color = color
    }
}

extension Photo: Persistable {
    init(entity: PhotoEntity) {
        self.init(
            categoryTitle: entity.categoryTitle,
            goalTitle: entity.goalTitle,
            imageData: entity.imageData,
            date: entity.date,
            color: entity.color
        )
    }
    
    func toEntity<T: PhotoEntity>() -> T {
        return T(
            categoryTitle: self.categoryTitle,
            goalTitle: self.goalTitle,
            imageData: self.imageData,
            date: self.date,
            color: self.color
        )
    }
}
