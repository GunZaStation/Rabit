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
    var didTapCloseCertPhotoCameraButton: PublishRelay<Void> = .init()
    var didTakeCertPhoto: PublishRelay<BehaviorRelay<Photo>> = .init()
    
    var didTapCategoryAddButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapGoalAddButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapCloseCategoryAddButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapClosePeriodSelectButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapCloseTimeSelectButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTakeCertPhotoSetCount = BehaviorRelay<Int>(value: 0)
    var didTapCloseGoalAddViewButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapCloseGoalDetailButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapCertPhotoCameraButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapCloseCertPhotoCameraButtonSetCount = BehaviorRelay<Int>(value: 0)
    
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
        
        didTapCloseCategoryAddButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseCategoryAddButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseCategoryAddButtonSetCount)
            .disposed(by: disposeBag)
        
        didTapClosePeriodSelectButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapClosePeriodSelectButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapClosePeriodSelectButtonSetCount)
            .disposed(by: disposeBag)
        
        didTapCloseTimeSelectButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseTimeSelectButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseTimeSelectButtonSetCount)
            .disposed(by: disposeBag)
        
        didTakeCertPhoto
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTakeCertPhotoSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTakeCertPhotoSetCount)
            .disposed(by: disposeBag)
        
        didTapCloseGoalAddViewButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseGoalAddViewButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseGoalAddViewButtonSetCount)
            .disposed(by: disposeBag)
        
        didTapCloseGoalDetailButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseGoalDetailButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseGoalDetailButtonSetCount)
            .disposed(by: disposeBag)
        
        didTapCertPhotoCameraButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCertPhotoCameraButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCertPhotoCameraButtonSetCount)
            .disposed(by: disposeBag)
        
        didTapCloseCertPhotoCameraButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseCertPhotoCameraButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseCertPhotoCameraButtonSetCount)
            .disposed(by: disposeBag)
    }
}
