import Foundation

struct Photo {
    let imageData: Data
    let date: Date
    var color: String

    init(
        imageData: Data,
        date: Date,
        color: String
    ) {
        self.imageData = imageData
        self.date = date
        self.color = color
    }
}

extension Photo: Persistable {
    init(entity: PhotoEntity) {
        self.init(
            imageData: entity.imageData,
            date: entity.date,
            color: entity.color
        )
    }
    
    func toEntity<T: PhotoEntity>() -> T {
        return T(
            imageData: self.imageData,
            date: self.date,
            color: self.color
        )
    }
}
