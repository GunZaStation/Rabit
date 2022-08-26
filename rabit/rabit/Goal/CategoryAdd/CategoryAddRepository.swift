import Foundation
import RxSwift

final class CategoryAddRepository {
    
    private let realmManager = RealmManager.shared
    
    func checkTitleDuplicated(input: String) -> Bool {
      
        realmManager.read(
            entity: GoalEntity.self,
            filter: "category == '\(input.trimmingCharacters(in: .whitespaces))'"
        ).count >= 1
    }
    
    func addCategory(goal: Goal) -> Single<Bool> {
        
        var result = true
        do {
            try realmManager.write(entity: goal.toEntity())
        } catch {
            result = false
        }
        
        return .create { single in
            single(.success(result))
            return Disposables.create()
        }
    }
}
