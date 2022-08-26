import Foundation
import RxSwift

final class GoalListRepository {
    
    private let realmRepository = RealmRepository.shared
    private var goalList: [Category] = []
    
    init() {
        setMockData()
    }
    
    func fetchGoalListData() -> Single<[Category]> {
        let goalList = goalList
        
        return .create { single in
            single(.success(goalList))
            return Disposables.create()
        }
    }
}

extension GoalListRepository {
    
    private func setMockData() {
        var goalMap: [String:Category] = [:]

        let goalEntities = realmRepository.read(entity: GoalEntity.self)
        let categoryEntities = realmRepository.read(entity: CategoryEntity.self)
        
        categoryEntities.forEach {
            goalMap[$0.title] = Category(title: $0.title, details: [])
        }
        
        goalEntities.forEach {
            let goal = Goal(entity: $0)
            goalMap[$0.category]?.items.append(goal)
        }

        goalList.append(contentsOf: goalMap.values)
    }
}

