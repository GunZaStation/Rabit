import Foundation
import RxSwift

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]>
}

final class AlbumRepository: AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]> {

        return Observable.create { observer in

            let realmManager = RealmManager.shared

            let fetchedGoalDetailData = realmManager.read(entity: CategoryEntity.self)

            var albumData = [Album]()

            fetchedGoalDetailData.forEach {
                let categoryTitle = $0.title

                let fetchedPhotoData = realmManager
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
}
