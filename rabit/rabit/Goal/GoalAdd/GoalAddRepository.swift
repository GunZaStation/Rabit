import Foundation
import RxSwift

struct GoalAddRepository {
    
    private let realmManager = RealmManager.shared

    func addGoal(_ goal: Goal) -> Single<Bool> {
        
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
