import Foundation
import RxSwift

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]>
}

final class AlbumRepository: AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]> {

        return Observable.create { observer in

            let realmManager = RealmRepository.shared

            let fetchedData = realmManager.read(entity: PhotoEntity.self)

            var albumData = Album(date: fetchedData.first?.date ?? Date(), items: [])

            fetchedData.forEach {
                albumData.items.append(Photo(entity: $0))
            }

            observer.onNext([albumData])

            return Disposables.create()
        }
    }
}
