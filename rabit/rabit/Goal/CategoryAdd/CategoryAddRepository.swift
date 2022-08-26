import Foundation
import RxSwift

final class CategoryAddRepository {
    
    private let realmRepository = RealmRepository.shared
    
    func checkTitleDuplicated(input: String) -> Bool {
      
        realmRepository.read(
            entity: CategoryEntity.self,
            filter: "category == '\(input.trimmingCharacters(in: .whitespaces))'"
        ).count >= 1
    }
    
    func addCategory(_ category: Category) -> Single<Bool> {
        
        var result = true
        do {
            try realmRepository.write(entity: category.toEntity())
        } catch {
            result = false
        }
        
        return .create { single in
            single(.success(result))
            return Disposables.create()
        }
    }
}
