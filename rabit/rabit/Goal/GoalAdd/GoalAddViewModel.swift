import Foundation
import RxSwift
import RxRelay

protocol GoalAddViewModelInput {
    
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var periodFieldTouched: PublishRelay<Void> { get }
}

protocol GoalAddViewModelOutput {
    
    var periodSelectViewModel: PublishRelay<PeriodSelectViewModel> { get }
    var selectedPeriod: PublishRelay<Period> { get }
}

final class GoalAddViewModel: GoalAddViewModelInput, GoalAddViewModelOutput {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let periodFieldTouched = PublishRelay<Void>()
    let periodSelectViewModel = PublishRelay<PeriodSelectViewModel>()
    let selectedPeriod = PublishRelay<Period>()
    
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
            .withUnretained(self)
            .bind(onNext: { viewModel, subViewModel in
                viewModel.periodSelectViewModel.accept(subViewModel)
                navigation.showPeriodSelectView.accept(subViewModel)
            })
            .disposed(by: disposeBag)
        
        periodSelectViewModel
            .flatMapLatest { $0.selectedPeriod }
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)
    }
}
