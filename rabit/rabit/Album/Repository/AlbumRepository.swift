import Foundation
import RxSwift
import UIKit // MockData의 UIImage를 위해 임시적으로 import

protocol AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]>
}

final class AlbumRepository: AlbumRepositoryProtocol {
    func fetchAlbumData() -> Observable<[Album]> {
        let backgroundQueue = DispatchQueue(label: "albumRepository.queue")

        return Observable.create { observer in
            backgroundQueue.async {
                // 통신 중인 것처럼 보이게 하기 위해 2초 딜레이
                Thread.sleep(forTimeInterval: 2)

                // 통신 여부와 상관없이 MockData 반환
                let fetchedMockData = [
                    Album(date: Date(), items: [
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF"),
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF"),
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF")
                    ]),
                    Album(date: Date(), items: [
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF"),
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF"),
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF")
                    ]),
                    Album(date: Date(), items: [
                        Photo(imageData: UIImage(systemName: "pencil")!.pngData()!, date: Date(), color: "#FFFFFF"),
                    ])
                ]
               
                observer.onNext(fetchedMockData)
            }

            return Disposables.create()
        }
    }
}
