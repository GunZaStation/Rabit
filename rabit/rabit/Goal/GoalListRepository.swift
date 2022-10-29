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
        var cateogryMap: [String:Category] = [:]

        let goalEntities = realmManager.read(entity: GoalEntity.self)
        let categoryEntities = realmManager.read(entity: CategoryEntity.self)
        
        categoryEntities.forEach {
            cateogryMap[$0.title] = Category(entity: $0)
        }
        
        goalEntities.forEach {
            var goal = Goal(entity: $0)
            let goalTitle = goal.title
            let photoCount = realmManager.read(entity: PhotoEntity.self, filter: "goalTitle == '\(goalTitle)'").count
            goal.progress = photoCount
            cateogryMap[$0.category]?.items.append(goal)
        }
        
        return cateogryMap.values
                          .map { category in
                              var category = category
                              category.items.sort { $0.creationDate < $1.creationDate }
                              return category
                          }
                          .sorted { $0.creationDate < $1.creationDate }
    }
}

