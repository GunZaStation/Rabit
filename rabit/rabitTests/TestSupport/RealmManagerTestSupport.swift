import Foundation
import RealmSwift
@testable import rabit

final class RealmManagerMock: RealmManagable {
    static var shared = RealmManagerMock()
    
    init() { }
    
    var mockCategoryReadReturn: [CategoryEntity]?
    var mockPhotoReadRetrun: [PhotoEntity]?
    var mockGoalReadReturn: [GoalEntity]?
    
    var readCallCount = 0
    func read<T: Object>(entity: T.Type, filter query: String?) -> [T] {
        self.readCallCount += 1
        
        switch ObjectIdentifier(T.self) {
        case ObjectIdentifier(CategoryEntity.self):
            if let mockCategoryReadReturn = mockCategoryReadReturn as? [T] {
                return mockCategoryReadReturn
            }
        case ObjectIdentifier(PhotoEntity.self):
            if let mockPhotoReadRetrun = mockPhotoReadRetrun as? [T] {
                return mockPhotoReadRetrun
            }
        case ObjectIdentifier(GoalEntity.self):
            if let mockGoalReadReturn = mockGoalReadReturn as? [T] {
                return mockGoalReadReturn
            }
        default:
            return []
        }
        
        return []
    }
    
    var writeShouldSuccess: Bool?
    
    var writeCallCount = 0
    func write<T: Object>(entity: T) throws {
        self.writeCallCount += 1
        
        guard let writeShouldSuccess = writeShouldSuccess,
           writeShouldSuccess else {
            throw NSError(domain: "RealmManagerMock_writeError", code: 1)
        }
    }
    
    var updateShouldSuccess: Bool?
    
    var updateCallCount = 0
    func update<T: Object>(entity: T) throws {
        self.updateCallCount += 1
        
        guard let updateShouldSuccess = self.updateShouldSuccess,
           updateShouldSuccess else {
            throw NSError(domain: "RealmManagerMock_updateError", code: 2)
        }
    }
}
