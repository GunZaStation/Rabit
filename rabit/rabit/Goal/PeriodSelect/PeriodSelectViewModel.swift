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
    var dayData: BehaviorRelay<[Days]> { get }
}

final class PeriodSelectViewModel: PeriodSelectViewModelInput, PeriodSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()

    let selectedStartDate = PublishRelay<Date>()
    let selectedEndDate = PublishRelay<Date>()
    let dayData: BehaviorRelay<[Days]>

    private let usecase: CalendarManagable

    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        usecase: CalendarManagable,
        with periodStream: BehaviorRelay<Period>
    ) {
        self.usecase = usecase
        self.dayData = .init(value: usecase.days)
        bind(to: navigation, with: periodStream)
    }
    
    func bind(
        to navigation: GoalNavigation,
        with periodStream: BehaviorRelay<Period>
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
