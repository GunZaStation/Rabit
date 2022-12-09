import Foundation
import RxRelay
import RxSwift
@testable import rabit

final class GoalNavigationMock: GoalNavigation {
    var didTapCategoryAddButton: PublishRelay<Void> = .init()
    var didTapCloseCategoryAddButton: PublishRelay<Void> = .init()
    var didTapGoalAddButton: PublishRelay<rabit.Category> = .init()
    var didTapCloseGoalAddViewButton: PublishRelay<Void> = .init()
    var didTapPeriodSelectTextField: PublishRelay<BehaviorRelay<Period>> = .init()
    var didTapClosePeriodSelectButton: PublishRelay<Void> = .init()
    var didTapTimeSelectTextField: PublishRelay<BehaviorRelay<CertifiableTime>> = .init()
    var didTapCloseTimeSelectButton: PublishRelay<Void> = .init()
    var didTapGoal: PublishRelay<Goal> = .init()
    var didTapCloseGoalDetailButton: PublishRelay<Void> = .init()
    var didTapCertPhotoCameraButton: PublishRelay<Goal> = .init()
    var didTakeCertPhoto: PublishRelay<BehaviorRelay<Photo>> = .init()
    
    var didTapCategoryAddButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapGoalAddButtonSetCount = BehaviorRelay<Int>(value: 0)
    
    private var disposeBag: DisposeBag
    
    init() {
        self.disposeBag = DisposeBag()
        
        didTapCategoryAddButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCategoryAddButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCategoryAddButtonSetCount)
            .disposed(by: disposeBag)
        
        didTapGoalAddButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapGoalAddButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapGoalAddButtonSetCount)
            .disposed(by: disposeBag)
    }
}
