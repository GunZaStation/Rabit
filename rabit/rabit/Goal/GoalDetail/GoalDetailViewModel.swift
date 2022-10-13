import Foundation
import RxSwift
import RxRelay

protocol GoalDetailViewModelInput {
    
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var goalTitleInput: PublishRelay<String> { get }
    var goalSubtitleInput: PublishRelay<String> { get }
}

protocol GoalDetailViewModelOutput {
    
    var goalTitleOutput: BehaviorRelay<String> { get }
    var goalSubtitleOutput: BehaviorRelay<String> { get }
    var selectedPeriod: BehaviorRelay<Period> { get }
    var selectedTime: BehaviorRelay<CertifiableTime> { get }
}

final class GoalDetailViewModel: GoalDetailViewModelInput, GoalDetailViewModelOutput {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let goalTitleInput = PublishRelay<String>()
    let goalSubtitleInput = PublishRelay<String>()
    
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
    }
}

