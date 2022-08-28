import Foundation
import RxSwift
import RxRelay


protocol PeriodSelectViewModelInput {
    
    var dimmedViewTouched: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol PeriodSelectViewModelOutput {
    
    var selectedStartDate: PublishRelay<Date> { get }
    var selectedEndDate: PublishRelay<Date> { get }
    var selectedPeriod: PublishRelay<Period> { get }
}

final class PeriodSelectViewModel: PeriodSelectViewModelInput, PeriodSelectViewModelOutput {
    
    let dimmedViewTouched = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartDate = PublishRelay<Date>()
    let selectedEndDate = PublishRelay<Date>()
    let selectedPeriod = PublishRelay<Period>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation) {
        bind(to: navigation)
    }
    
    func bind(to navigation: GoalNavigation) {
        
        dimmedViewTouched
            .bind(to: navigation.closePeriodSelectView)
            .disposed(by: disposeBag)
        
        let period = Observable
                        .combineLatest(
                            selectedStartDate.asObservable(),
                            selectedEndDate.asObservable()
                        )
                        .map { Period(start: $0, end: $1) }
                        .share()
        
        saveButtonTouched
            .withLatestFrom(period)
            .withUnretained(self)
            .bind(onNext: { viewModel, period in
                viewModel.selectedPeriod.accept(period)
                navigation.closePeriodSelectView.accept(())
            })
            .disposed(by: disposeBag)
    }
}
