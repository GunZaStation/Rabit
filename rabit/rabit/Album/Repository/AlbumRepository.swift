import Foundation
import RxSwift

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Single<[Album]>
    func updateAlbumData(_ data: Photo) -> Single<Bool>
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
            try realmManager.update(entity: data.toEntity())
        } catch {
            result = false
        }

        return .create { single in
            single(.success(result))

            return Disposables.create()
        }
    }
}

private extension AlbumRepository {
    func getLatestAlbum() -> [Album] {
        let fetchedCategoryData = realmManager.read(entity: CategoryEntity.self)

        var albumData = [Album]()

        fetchedCategoryData.forEach {
            let categoryTitle = $0.title

            let fetchedPhotoData = realmManager.read(entity: PhotoEntity.self, filter: "categoryTitle == '\(categoryTitle)'")
                .map(Photo.init)

            if !fetchedPhotoData.isEmpty {
                albumData.append(Album(
                    categoryTitle: categoryTitle,
                    items: fetchedPhotoData
                ))
            }
        }

        return albumData
    }
}
