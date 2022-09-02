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
    
    var periodSelectViewModel: PublishRelay<PeriodSelectViewModel> { get }
    var timeSelectViewModel: PublishRelay<TimeSelectViewModel> { get }
    var selectedPeriod: PublishRelay<Period> { get }
    var selectedTime: PublishRelay<CertifiableTime> { get }
}

final class GoalAddViewModel: GoalAddViewModelInput, GoalAddViewModelOutput {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let periodFieldTouched = PublishRelay<Void>()
    let timeFieldTouched = PublishRelay<Void>()
    let periodSelectViewModel = PublishRelay<PeriodSelectViewModel>()
    let selectedPeriod = PublishRelay<Period>()
    let timeSelectViewModel = PublishRelay<TimeSelectViewModel>()
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
            .map { PeriodSelectViewModel(navigation: navigation) }
            .bind(to: periodSelectViewModel)
            .disposed(by: disposeBag)
        
        periodSelectViewModel
            .map { $0 }
            .bind(to: navigation.showPeriodSelectView)
            .disposed(by: disposeBag)
        
        periodSelectViewModel
            .flatMapLatest { $0.selectedPeriod }
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)
        
        timeFieldTouched
            .map { TimeSelectViewModel(navigation: navigation) }
            .bind(to: timeSelectViewModel)
            .disposed(by: disposeBag)
        
        timeSelectViewModel
            .bind(to: navigation.showTimeSelectView)
            .disposed(by: disposeBag)
        
        timeSelectViewModel
            .flatMapLatest { $0.selectedTime }
            .bind(to: selectedTime)
            .disposed(by: disposeBag)
    }
}
