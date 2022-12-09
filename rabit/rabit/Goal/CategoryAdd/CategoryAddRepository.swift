import Foundation
import RxSwift

protocol CategoryAddRepositoryProtocol {
    func checkTitleDuplicated(input: String) -> Bool
    func addCategory(_ category: Category) -> Single<Bool>
}

final class CategoryAddRepository: CategoryAddRepositoryProtocol {
    
    private let realmManager = RealmManager.shared
    private var categoryTitleList: [String] = []
    
    init() {
        categoryTitleList = realmManager.read(entity: CategoryEntity.self)
                                        .map { $0.title }
    }
    
    func checkTitleDuplicated(input: String) -> Bool {
        categoryTitleList.contains(input)
    }
    
    func addCategory(_ category: Category) -> Single<Bool> {
        
        var result = true
        do {
            try realmManager.write(entity: category.toEntity())
        } catch {
            result = false
        }
        
        return .create { single in
            single(.success(result))
            return Disposables.create()
        }
    }
}
