import Foundation
import RxSwift

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Single<[Album]>
    func updateAlbumData(_ data: Photo) -> Single<Bool>
    func savePhotoImageData(_ data: Data, name: String) -> Single<Bool>
}

final class AlbumRepository: AlbumRepositoryProtocol {

    private let realmManager = RealmManager.shared

    func fetchAlbumData() -> Single<[Album]> {
        
        let fetchedAlbumData = getLatestAlbum()

        return .create { single in
            single(.success(fetchedAlbumData))

            return Disposables.create()
        }
    }

    func updateAlbumData(_ data: Photo) -> Single<Bool> {

        var result = true
        do {
            try realmManager.update(object: data)
        } catch {
            result = false
        }

        return .create { single in
            single(.success(result))

            return Disposables.create()
        }
    }
    
    func savePhotoImageData(_ data: Data, name: String) -> Single<Bool> {
        
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return .create { single in
                single(.success(false))
                
                return Disposables.create()
            }
        }
        var result = true
        
        let imageURL = documentDirectory.appendingPathComponent(name)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try? FileManager.default.removeItem(at: imageURL)
        }
        
        do {
            try data.write(to: imageURL)
        } catch {
            result = false
        }
        
        return .create { single in
            single(.success(result))
            
            return Disposables.create()
        }
    }
}

// MARK: - Private Methods
private extension AlbumRepository {
    func getLatestAlbum() -> [Album] {
        
        let fetchedCategoryData = realmManager.read(entity: CategoryEntity.self)

        var albumData = [Album]()

        fetchedCategoryData.forEach {
            let categoryTitle = $0.title

            let fetchedPhotoData = realmManager.read(
                entity: PhotoEntity.self,
                filter: "categoryTitle == '\(categoryTitle)'"
            )
                .map(Photo.init)
                .map { [weak self] (photo) -> Photo in
                    var photo = photo
                    photo.imageData = self?.loadImageDataFromDocumentDirectory(imageName: photo.imageName)
                    return photo
                }
                .sorted { $0.date < $1.date }

            if !fetchedPhotoData.isEmpty {
                albumData.append(Album(
                    categoryTitle: categoryTitle,
                    items: fetchedPhotoData
                ))
            }
        }

        return albumData
    }
    
    func loadImageDataFromDocumentDirectory(imageName: String) -> Data? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
            let imageURL = URL(fileURLWithPath: directoryPath)
                .appendingPathComponent(imageName)
            
            return try? Data(contentsOf: imageURL)
        } else {
            return nil
        }
    }
}
