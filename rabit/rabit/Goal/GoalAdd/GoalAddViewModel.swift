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
    var goalAddResult: PublishRelay<Bool> { get }
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
    let goalAddResult = PublishRelay<Bool>()
    
    let selectedPeriod = BehaviorRelay<Period>(value: Period())
    let selectedTime = BehaviorRelay<CertifiableTime>(value: CertifiableTime())
    
    private let category: Category
    private let repository: GoalAddRepository
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation,
         category: Category,
         repository: GoalAddRepository = GoalAddRepository()) {
        self.category = category
        self.repository = repository
        bind(to: navigation)
    }
}

private extension GoalAddViewModel {
    
    func bind(to navigation: GoalNavigation) {
                
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
                            category: $0.category.title
                        )
                    }
                    .share()
        
        saveButtonTouched
            .withLatestFrom(goal)
            .withUnretained(self)
            .flatMapLatest{
                return $0.repository.addGoal($1)
            }
            .bind(to: goalAddResult)
            .disposed(by: disposeBag)
                
        goalAddResult
            .bind(onNext: { isSuccess in
                if isSuccess {
                    navigation.closeGoalAddView.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
}
