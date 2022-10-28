import Foundation
import RxSwift

struct GoalAddRepository {
    
    private let realmManager = RealmManager.shared
    private var goalTitleList: [String] = []
    
    init(category: Category) {
        goalTitleList = realmManager.read(
                            entity: GoalEntity.self,
                            filter: "category =='\(category.title)'"
                        ).map { $0.title }
    }

    func checkTitleDuplicated(title: String) -> Bool {
        goalTitleList.contains(title)
    }
    
    func checkTitleDuplicated(title: String, category: String) -> Bool {
        
        guard !title.isEmpty else { return false }
        
        return realmManager.read(
            entity: GoalEntity.self,
            filter: "title=='\(title)' && category=='\(category)'"
        ).count >= 1        
    }

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
