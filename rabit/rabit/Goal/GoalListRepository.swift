import Foundation
import RxSwift

final class GoalListRepository {
    
    private let realmRepository = RealmRepository.shared
    private var goalList: [Goal] = []
    
    init() {
        setMockData()
    }
    
    func fetchGoalListData() -> Single<[Goal]> {
        let goalList = goalList
        
        return .create { single in
            single(.success(goalList))
            return Disposables.create()
        }
    }
}

extension GoalListRepository {
    
    private func setMockData() {
        var goalMap: [String:Goal] = [:]

        let goalDetailEntities = realmRepository.read(entity: GoalDetailEntity.self)
        let goalEntities = realmRepository.read(entity: GoalEntity.self)
        
        goalEntities.forEach {
            goalMap[$0.category] = Goal(category: $0.category, details: [])
        }
        
        goalDetailEntities.forEach {
            let goalDetail = GoalDetail(entity: $0)
            goalMap[$0.category]?.items.append(goalDetail)
        }

        goalList.append(contentsOf: goalMap.values)
    }
}

