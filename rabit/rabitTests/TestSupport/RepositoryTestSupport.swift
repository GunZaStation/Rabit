import Foundation
import RxSwift
@testable import rabit

final class AlbumRepositoryMock: AlbumRepositoryProtocol {
    
    var mockAlbum: [Album]?
    
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
    
    var mockUpdateResult: Bool?
    
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
    
    var mockSavePhotoImageResult: Bool?
    
    var savePhotoImageDataCallCount = 0
    var savePhotoImageData: Data?
    var savePhotoImageDataName: String?
    func savePhotoImageData(_ data: Data, name: String) -> Single<Bool> {
        self.savePhotoImageDataCallCount += 1
        self.savePhotoImageData = data
        self.savePhotoImageDataName = name
        
        return .create { [weak self] single in
            guard let mockSavePhotoImageResult = self?.mockSavePhotoImageResult else {
                single(.success(false))
                
                return Disposables.create()
            }
            
            single(.success(mockSavePhotoImageResult))

            return Disposables.create()
        }
    }
}

final class GoalListRepositoryMock: GoalListRepositoryProtocol {
    
    var mockCategory: [rabit.Category]?
    
    var fetchGoalListDataCallCount = 0
    func fetchGoalListData() -> Single<[rabit.Category]> {
        self.fetchGoalListDataCallCount += 1
        
        return .create  { [weak self] single in
            guard let mockCategory = self?.mockCategory else {
                single(.success([]))
                return Disposables.create()
            }

            single(.success(mockCategory))
            
            return Disposables.create()
        }
    }
}

final class CategoryAddRepositoryMock: CategoryAddRepositoryProtocol {
    
    var mockCheckTitleDuplicatedOutput: Bool?
    
    var checkTitleDuplicatedCallCount = 0
    var checkTitlePuplicatedInput: String?
    func checkTitleDuplicated(input: String) -> Bool {
        self.checkTitleDuplicatedCallCount += 1
        self.checkTitlePuplicatedInput = input
        
        if let mockCheckTitleDuplicatedOutput = mockCheckTitleDuplicatedOutput {
            return mockCheckTitleDuplicatedOutput
        }
        
        return true
    }
    
    var mockAddCategoryResult: Bool?
    
    var addCategoryCallCount = 0
    var addCategoryInputCategory: rabit.Category?
    func addCategory(_ category: rabit.Category) -> Single<Bool> {
        self.addCategoryCallCount += 1
        self.addCategoryInputCategory = category
        
        return .create { [weak self] single in
            guard let mockAddCategoryResult = self?.mockAddCategoryResult else {
                single(.success(false))
                
                return Disposables.create()
            }

            single(.success(mockAddCategoryResult))
            
            return Disposables.create()
        }
    }
}
