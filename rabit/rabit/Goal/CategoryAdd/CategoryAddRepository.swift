import Foundation
import RxSwift

final class CategoryAddRepository {
    
    private let realmRepository = RealmRepository.shared
    
    func checkTitleDuplicated(input: String) -> Bool {
      
        realmRepository.read(
            entity: GoalEntity.self,
            filter: "category == '\(input)'"
        ).count >= 1
    }
    
    func addCategory(goal: Goal) -> Single<Bool> {
        
        //없으면 realm에 쓰기 시도 -> 예외 발생시에는 Single(false)로 리턴
        realmRepository.write(entity: goal.toEntity())
        
        return .create { single in
            single(.success(true))
            return Disposables.create()
        }
    }
}
