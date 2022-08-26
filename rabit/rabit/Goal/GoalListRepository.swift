import Foundation
import RxSwift

final class GoalListRepository {
    
    private let realmManager = RealmManager.shared

    func fetchGoalListData() -> Single<[Category]> {
        let goalList = getLatestGoals()
        
        return .create { single in
            single(.success(goalList))
            return Disposables.create()
        }
    }
}

extension GoalListRepository {
    
    private func getLatestGoals() -> [Category] {
        var goalMap: [String:Category] = [:]

        let goalEntities = realmManager.read(entity: GoalEntity.self)
        let categoryEntities = realmManager.read(entity: CategoryEntity.self)
        
        categoryEntities.forEach {
            goalMap[$0.title] = Category(title: $0.title)
        }
        
        goalEntities.forEach {
            let goal = Goal(entity: $0)
            goalMap[$0.category]?.items.append(goal)
        }

//        goalList.append(contentsOf: goalMap.values)
        return goalMap.values.map { $0 }
    }
}

