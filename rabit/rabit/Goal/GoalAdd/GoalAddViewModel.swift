import Foundation
import RxSwift
import RxRelay

protocol GoalAddViewModelInput {
    
    var saveButtonDisabled: PublishRelay<Bool> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var periodFieldTouched: PublishRelay<Void> { get }
    var timeFieldTouched: PublishRelay<Void> { get }
    var goalTitleInput: PublishRelay<String> { get }
    var goalSubtitleInput: PublishRelay<String> { get }
    var goalAddResult: PublishRelay<Bool> { get }
}

protocol GoalAddViewModelOutput {
    
    var selectedPeriod: BehaviorRelay<Period> { get }
    var selectedTime: BehaviorRelay<CertifiableTime> { get }
}

protocol GoalAddViewModelProtocol: GoalAddViewModelInput, GoalAddViewModelOutput {}

final class GoalAddViewModel: GoalAddViewModelProtocol {
    
    let saveButtonDisabled = PublishRelay<Bool>()
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let periodFieldTouched = PublishRelay<Void>()
    let timeFieldTouched = PublishRelay<Void>()
    let goalTitleInput = PublishRelay<String>()
    let goalSubtitleInput = PublishRelay<String>()
    let goalAddResult = PublishRelay<Bool>()
    
    let selectedPeriod = BehaviorRelay<Period>(value: Period())
    let selectedTime = BehaviorRelay<CertifiableTime>(value: CertifiableTime())
    
    private let repository: GoalAddRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation,
         category: Category,
         repository: GoalAddRepositoryProtocol) {
        self.repository = repository
        
        bind(to: navigation, with: category)
    }
}

private extension GoalAddViewModel {
    
    func bind(to navigation: GoalNavigation, with category: Category) {
        
        let goalTitleVertification = goalTitleInput
                                        .withUnretained(self)
                                        .map { viewModel, titleInput -> (Bool, Bool) in
                                            let isEmpty = titleInput.isEmpty || titleInput.count <= 0
                                            let isDuplicated = viewModel.repository.checkTitleDuplicated(title: titleInput)
                                            return (isEmpty, isDuplicated)
                                        }
                                        .share()
        
        goalTitleVertification
            .map { $0 || $1 }
            .bind(to: saveButtonDisabled)
            .disposed(by: disposeBag)
                        
        closeButtonTouched
            .bind(to: navigation.didTapCloseGoalAddViewButton)
            .disposed(by: disposeBag)
        
        periodFieldTouched
            .withUnretained(self)
            .map { $0.0.selectedPeriod }
            .bind(to: navigation.didTapPeriodSelectTextField)
            .disposed(by: disposeBag)
        
        timeFieldTouched
            .withUnretained(self)
            .map { $0.0.selectedTime }
            .bind(to: navigation.didTapTimeSelectTextField)
            .disposed(by: disposeBag)
        
        let goal = Observable
                    .combineLatest(
                        goalTitleInput,
                        goalSubtitleInput,
                        selectedPeriod,
                        selectedTime
                    )
                    .withUnretained(self)
                    .map {
                        Goal(
                            title: $1.0,
                            subtitle: $1.1,
                            period: $1.2,
                            certTime: $1.3,
                            category: category.title
                        )
                    }
                    .share()
        
        saveButtonTouched
            .withLatestFrom(goal)
            .withUnretained(self)
            .flatMapLatest{
                $0.repository.addGoal($1)
            }
            .bind(to: goalAddResult)
            .disposed(by: disposeBag)
                
        goalAddResult
            .bind(onNext: { isSuccess in
                if isSuccess {
                    navigation.didTapCloseGoalAddViewButton.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
}
