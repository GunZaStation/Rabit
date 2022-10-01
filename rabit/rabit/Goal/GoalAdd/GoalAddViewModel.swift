import Foundation
import RxSwift
import RxRelay

protocol GoalAddViewModelInput {
    
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var periodFieldTouched: PublishRelay<Void> { get }
    var timeFieldTouched: PublishRelay<Void> { get }
    var goalTitleInput: PublishRelay<String> { get }
    var goalSubtitleInput: PublishRelay<String> { get }
}

protocol GoalAddViewModelOutput {
    
    var selectedPeriod: BehaviorRelay<Period> { get }
    var selectedTime: BehaviorRelay<CertifiableTime> { get }
}

final class GoalAddViewModel: GoalAddViewModelInput, GoalAddViewModelOutput {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let periodFieldTouched = PublishRelay<Void>()
    let timeFieldTouched = PublishRelay<Void>()
    let goalTitleInput = PublishRelay<String>()
    let goalSubtitleInput = PublishRelay<String>()
    let selectedPeriod = BehaviorRelay<Period>(value: Period())
    let selectedTime = BehaviorRelay<CertifiableTime>(value: CertifiableTime())
    
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
            .map { $0.0.selectedPeriod }
            .bind(to: navigation.showPeriodSelectView)
            .disposed(by: disposeBag)
        
        timeFieldTouched
            .withUnretained(self)
            .map { $0.0.selectedTime }
            .bind(to: navigation.showTimeSelectView)
            .disposed(by: disposeBag)
    }
}
