import Foundation
import RxSwift
@testable import rabit

final class AlbumRepositoryMock: AlbumRepositoryProtocol {
    
    var mockAlbum: [Album]?
    var mockUpdateResult: Bool?
    
    var fetchAlbumDataCallCount = 0
    func fetchAlbumData() -> Single<[Album]> {
        self.fetchAlbumDataCallCount += 1
        
        return .create { [weak self] single in
            guard let mockAlbum = self?.mockAlbum else {
                single(.success([Album(categoryTitle: "", items: [])]))
                return Disposables.create()
            }
            
            single(.success(mockAlbum))
            
            return Disposables.create()
        }
    }
    
    var updateAlbumDataCallCount = 0
    var updateAlbumData: Photo?
    func updateAlbumData(_ data: Photo) -> Single<Bool> {
        self.updateAlbumDataCallCount += 1
        self.updateAlbumData = data
        
        return .create { [weak self] single in
            guard let mockUpdateResult = self?.mockUpdateResult else {
                single(.success(false))
                return Disposables.create()
            }

            single(.success(mockUpdateResult))
            
            return Disposables.create()
        }
    }
    
    var savePhotoImageDataCallCount = 0
    var savePhotoImageData: Data?
    var savePhotoImageDataName: String?
    func savePhotoImageData(_ data: Data, name: String) -> Single<Bool> {
        self.savePhotoImageDataCallCount += 1
        self.savePhotoImageData = data
        self.savePhotoImageDataName = name
        
        return .create { _ in
            return Disposables.create()
        }
    }
}
