import Foundation
import RxSwift

protocol GoalListRepositoryProtocol {
    func fetchGoalListData() -> Single<[Category]>
}

final class GoalListRepository: GoalListRepositoryProtocol {
    
    private let realmManager: RealmManagable

    init(realmManager: RealmManagable = RealmManager.shared) {
        self.realmManager = realmManager
    }
    
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

        let goalEntities = realmManager.read(
            entity: GoalEntity.self,
            filter: nil
        )
                                       .sorted { $0.createdDate < $1.createdDate }
        let categoryEntities = realmManager.read(
            entity: CategoryEntity.self,
            filter: nil
        )
        
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
        
        return Array(categoryMap.values).sorted { $0.createdDate < $1.createdDate }
    }
}

