import Foundation
import RxSwift
import RxRelay

protocol GoalDetailViewModelInput {
    
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var goalTitleInput: PublishRelay<String> { get }
    var goalSubtitleInput: PublishRelay<String> { get }
    var showCertPhotoCameraView: PublishRelay<Void> { get }
}

protocol GoalDetailViewModelOutput {
    
    var goalTitleOutput: BehaviorRelay<String> { get }
    var goalSubtitleOutput: BehaviorRelay<String> { get }
    var selectedPeriod: BehaviorRelay<Period> { get }
    var selectedTime: BehaviorRelay<CertifiableTime> { get }
}

protocol GoalDetailViewModelProtocol: GoalDetailViewModelInput, GoalDetailViewModelOutput {}

final class GoalDetailViewModel: GoalDetailViewModelProtocol {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let goalTitleInput = PublishRelay<String>()
    let goalSubtitleInput = PublishRelay<String>()
    let showCertPhotoCameraView = PublishRelay<Void>()
    
    let selectedPeriod: BehaviorRelay<Period>
    let selectedTime: BehaviorRelay<CertifiableTime>
    let goalTitleOutput: BehaviorRelay<String>
    let goalSubtitleOutput: BehaviorRelay<String>
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation,
         goal: Goal) {
        
        goalTitleOutput = BehaviorRelay(value: goal.title)
        goalSubtitleOutput = BehaviorRelay(value: goal.subtitle)
        selectedPeriod = BehaviorRelay(value: goal.period)
        selectedTime = BehaviorRelay(value: goal.certTime)
        bind(to: navigation, with: goal)
    }
}

private extension GoalDetailViewModel {
    
    func bind(to navigation: GoalNavigation, with goal: Goal) {
        
        closeButtonTouched
            .bind(to: navigation.didTapCloseGoalDetailButton)
            .disposed(by: disposeBag)
        
        showCertPhotoCameraView
            .map { goal }
            .bind(to: navigation.didTapCertPhotoCameraButton)
            .disposed(by: disposeBag)
     }
}
