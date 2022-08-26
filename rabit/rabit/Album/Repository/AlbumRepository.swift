import Foundation
import RxSwift

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]>
}

final class AlbumRepository: AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]> {

        return Observable.create { observer in

            let realmManager = RealmManager.shared

            let fetchedGoalDetailData = realmManager.read(entity: GoalEntity.self)
            let fetchedPhotoData = realmManager.read(entity: PhotoEntity.self)

            var albumData = [Album]()

            fetchedGoalDetailData.forEach {
                let categoryTitle = $0.category

                let filteredPhotoData = fetchedPhotoData.filter("categoryTitle == '\(categoryTitle)'")
                let transformedPhotoData = filteredPhotoData.toArray(ofType: PhotoEntity.self).map {
                    Photo(entity: $0)
                }

                albumData.append(Album(categoryTitle: categoryTitle, items: transformedPhotoData))
            }

            observer.onNext(albumData)

            return Disposables.create()
        }
    }
}
