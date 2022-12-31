import Foundation
import RxSwift

enum GoalEditError: Error {
    case goalEditFailure
}

protocol GoalDetailRepositoryProtocol {
    
    func updateGoalDetail(_ goal: Goal) -> Single<Result<Goal,Error>>
}

struct GoalDetailRepository: GoalDetailRepositoryProtocol {
    
    private let realmManager = RealmManager.shared
    
    func updateGoalDetail(_ goal: Goal) -> Single<Result<Goal,Error>> {
        
        realmManager.update(object: goal)
            .debug()
            .map { _ in .success(goal) }
            .catchAndReturn(.failure(GoalEditError.goalEditFailure))
    }
}
