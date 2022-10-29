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

private extension GoalListRepository {
    
    func getLatestGoals() -> [Category] {
        var categoryMap: [String:Category] = [:]

        let goalEntities = realmManager.read(entity: GoalEntity.self)
                                       .sorted { $0.creationDate < $1.creationDate }
        let categoryEntities = realmManager.read(entity: CategoryEntity.self)
        
        categoryEntities.forEach {
            categoryMap[$0.title] = Category(entity: $0)
        }
        
        goalEntities.forEach {
            var goal = Goal(entity: $0)
            let goalTitle = goal.title
            let photoCount = realmManager.read(entity: PhotoEntity.self, filter: "goalTitle == '\(goalTitle)'").count
            goal.progress = photoCount
            categoryMap[$0.category]?.items.append(goal)
        }
        
        return Array(categoryMap.values).sorted { $0.creationDate < $1.creationDate }
    }
}

