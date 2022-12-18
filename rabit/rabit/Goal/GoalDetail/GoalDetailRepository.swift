import Foundation
import RxSwift

enum GoalEditError: Error {
    case goalEditFailure
}

protocol GoalDetailRepositoryProtocol {
    
    func updateGoalDetail(_ goal: Goal) -> Single<Result<Goal,GoalEditError>>
}

struct GoalDetailRepository: GoalDetailRepositoryProtocol {
    
    private let realmManager = RealmManager.shared
    
    func updateGoalDetail(_ goal: Goal) -> Single<Result<Goal,GoalEditError>> {
        
        .create { single in
            do {
                try realmManager.update(entity: goal.toEntity())
                single(.success(.success(goal)))
            } catch {
                single(.success(.failure(.goalEditFailure)))
            }

            return Disposables.create()
        }
    }
}
