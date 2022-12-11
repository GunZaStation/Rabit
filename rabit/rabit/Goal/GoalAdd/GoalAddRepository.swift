import Foundation
import RxSwift

protocol GoalAddRepositoryProtocol {
    func checkTitleDuplicated(title: String) -> Bool
    func addGoal(_ goal: Goal) -> Single<Bool>
}

struct GoalAddRepository: GoalAddRepositoryProtocol {
    
    private let realmManager: RealmManagable
    private var goalTitleList: [String] = []
    
    init(
        category: Category,
        realmManager: RealmManagable = RealmManager.shared
    ) {
        self.realmManager = realmManager
        goalTitleList = realmManager.read(
                            entity: GoalEntity.self,
                            filter: "category =='\(category.title)'"
                        ).map { $0.title }
    }

    func checkTitleDuplicated(title: String) -> Bool {
        goalTitleList.contains(title)
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
