import Foundation
import RxSwift

enum RepoError: String, Error {
    case deleteError = "delete goal error"
    case realmError = "realm error"
}

final class GoalListRepository {
    
    private let realmManager = RealmManager.shared

    func fetchGoalListData() -> Single<[Category]> {
        let goalList = getLatestGoals()
        
        return .create { single in
            single(.success(goalList))
            return Disposables.create()
        }
    }
    
    //삭제 대상이 되는 특정 Entity를 우선 읽어들인 후, 삭제 트랜잭션으로 전달
    func deleteGoal(_ goal: Goal) -> Single<Result<Goal,Error>> {
        
        return .create { [weak self] single in
            guard let realmManager = self?.realmManager,
                  let goalEntity = realmManager.read(entity: GoalEntity.self, filter: "title == '\(goal.title)'").first else {
                single(.success(.failure(RepoError.deleteError)))
                return Disposables.create { }
            }
            
            do {
                try realmManager.delete(entity: goalEntity)
                single(.success(.success(goal)))
            } catch {
                single(.success(.failure(RepoError.realmError)))
            }
            
            return Disposables.create { }
        }
    }
}

private extension GoalListRepository {
    
    func getLatestGoals() -> [Category] {
        var categoryMap: [String:Category] = [:]

        let goalEntities = realmManager.read(entity: GoalEntity.self)
                                       .sorted { $0.createdDate < $1.createdDate }
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
        
        return Array(categoryMap.values).sorted { $0.createdDate < $1.createdDate }
    }
}

