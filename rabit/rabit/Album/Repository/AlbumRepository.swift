import Foundation
import RxSwift

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]>
    func updateAlbumData(_ data: Photo) -> Single<Bool>
}

final class AlbumRepository: AlbumRepositoryProtocol {

    private let realmManager = RealmManager.shared

    func fetchAlbumData() -> Observable<[Album]> {

        return Observable.create { [weak self] observer in

            guard let self = self else { return Disposables.create() }

            let fetchedGoalDetailData = self.realmManager.read(entity: CategoryEntity.self)

            var albumData = [Album]()

            fetchedGoalDetailData.forEach {
                let categoryTitle = $0.title

                let fetchedPhotoData = self.realmManager
                    .read(
                        entity: PhotoEntity.self,
                        filter: "categoryTitle == '\(categoryTitle)'"
                    )
                    .map { Photo(entity: $0) }

                if !fetchedPhotoData.isEmpty {
                    albumData.append(Album(categoryTitle: categoryTitle, items: fetchedPhotoData))
                }
            }

            observer.onNext(albumData)

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
