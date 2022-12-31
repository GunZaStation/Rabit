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
    
    private let repository: GoalDetailRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation,
         repository: GoalDetailRepositoryProtocol,
         goal: Goal) {
        self.repository = repository
        
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
            .map { goal }
            .bind(to: navigation.didTapCertPhotoCameraButton)
            .disposed(by: disposeBag)
        
        showCertPhotoCameraView
            .map { goal }
            .bind(to: navigation.didTapCertPhotoCameraButton)
            .disposed(by: disposeBag)
        
        let goalEditInfo = Observable
            .combineLatest(goalTitleInput, goalSubtitleInput)
            .map { (title, subtitle) -> Goal in
                Goal(
                    uuid: goal.uuid,
                    title: title,
                    subtitle: subtitle,
                    progress: goal.progress,
                    period: goal.period,
                    certTime: goal.certTime,
                    category: goal.category,
                    createdDate: goal.createdDate
                )
            }
            .share()
        
        saveButtonTouched
            .withLatestFrom(goalEditInfo)
            .withUnretained(self)
            .flatMapLatest { viewModel, goal in
                viewModel.repository.updateGoalDetail(goal)
            }
            .withUnretained(self)
            .bind(onNext: { viewModel, result in
                switch result {
                case .success(let goalEditInfo):
                    viewModel.goalTitleOutput.accept(goalEditInfo.title)
                    viewModel.goalSubtitleOutput.accept(goalEditInfo.subtitle)
                case .failure(_):
                    viewModel.goalTitleOutput.accept(goal.title)
                    viewModel.goalSubtitleOutput.accept(goal.subtitle)
                }
            })
            .disposed(by: disposeBag)
     }
}
