import Foundation
import RxSwift
import RxRelay

protocol PeriodSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol PeriodSelectViewModelOutput {
    
    var selectedStartDate: PublishRelay<Date> { get }
    var selectedEndDate: PublishRelay<Date> { get }
}

final class PeriodSelectViewModel: PeriodSelectViewModelInput, PeriodSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartDate = PublishRelay<Date>()
    let selectedEndDate = PublishRelay<Date>()
    
    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        with periodStream: PublishRelay<Period>
    ) {
        bind(to: navigation, with: periodStream)
    }
    
    func bind(
        to navigation: GoalNavigation,
        with periodStream: PublishRelay<Period>
    ) {
        
        closingViewRequested
            .bind(to: navigation.closePeriodSelectView)
            .disposed(by: disposeBag)
        
        let period = Observable.combineLatest(
                        selectedStartDate.asObservable(),
                        selectedEndDate.asObservable()
                    )
                    .map { Period(start: $0, end: $1) }
                    .share()
        
        saveButtonTouched
            .withLatestFrom(period)
            .bind(to: periodStream)
            .disposed(by: disposeBag)
    }
}
