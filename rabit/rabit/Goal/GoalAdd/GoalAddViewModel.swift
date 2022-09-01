import Foundation
import RxSwift
import RxRelay

protocol GoalAddViewModelInput {
    
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var periodFieldTouched: PublishRelay<Void> { get }
    var timeFieldTouched: PublishRelay<Void> { get }
}

protocol GoalAddViewModelOutput {
    
    var selectedPeriod: PublishRelay<Period> { get }
    var selectedTime: PublishRelay<CertifiableTime> { get }
}

final class GoalAddViewModel: GoalAddViewModelInput, GoalAddViewModelOutput {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let periodFieldTouched = PublishRelay<Void>()
    let timeFieldTouched = PublishRelay<Void>()
    let selectedPeriod = PublishRelay<Period>()
    let selectedTime = PublishRelay<CertifiableTime>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation) {
        bind(to: navigation)
    }
}

private extension GoalAddViewModel {
    
    func bind(to navigation: GoalNavigation) {
        
        saveButtonTouched
            .bind(to: navigation.closeGoalAddView)
            .disposed(by: disposeBag)
        
        closeButtonTouched
            .bind(to: navigation.closeGoalAddView)
            .disposed(by: disposeBag)
        
        periodFieldTouched
            .withUnretained(self)
            .map { viewModel, _ in
                viewModel.selectedPeriod
            }
            .bind(onNext: navigation.showPeriodSelectView)
            .disposed(by: disposeBag)
        
        timeFieldTouched
            .withUnretained(self)
            .map { viewModel, _ in viewModel.selectedTime }
            .bind(onNext: navigation.showTimeSelectView)
            .disposed(by: disposeBag)
    }
}
