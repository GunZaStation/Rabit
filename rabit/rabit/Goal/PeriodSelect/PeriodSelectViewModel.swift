import Foundation
import RxSwift
import RxRelay

protocol PeriodSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol PeriodSelectViewModelOutput {
    
    var dayData: BehaviorRelay<[Days]> { get }
    var selectedPeriod: BehaviorRelay<Period> { get }
    var selectedDay: PublishRelay<Day> { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
}

final class PeriodSelectViewModel: PeriodSelectViewModelInput, PeriodSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()

    let dayData: BehaviorRelay<[Days]>
    let selectedPeriod: BehaviorRelay<Period>
    let selectedDay = PublishRelay<Day>()
    let saveButtonState = BehaviorRelay<Bool>(value: false)

    private let usecase: CalendarManagable

    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        usecase: CalendarManagable,
        with periodStream: BehaviorRelay<Period>
    ) {
        self.usecase = usecase
        self.dayData = .init(value: usecase.days)
        self.selectedPeriod = .init(value: periodStream.value)
        bind(to: navigation, with: periodStream)
    }
    
    func bind(
        to navigation: GoalNavigation,
        with periodStream: BehaviorRelay<Period>
    ) {
        
        closingViewRequested
            .bind(to: navigation.closePeriodSelectView)
            .disposed(by: disposeBag)
        
        saveButtonTouched
            .withLatestFrom(selectedPeriod)
            .bind(to: periodStream)
            .disposed(by: disposeBag)

        selectedDay
            .withUnretained(self)
            .bind(onNext: { viewModel, selectedDay in
                viewModel.usecase.updateSelectedDay(with: selectedDay)
            })
            .disposed(by: disposeBag)

        let selectedStartDate = usecase.selectedStartDay.compactMap(\.?.date)

        usecase.selectedEndDay
            .compactMap(\.?.date)
            .withLatestFrom(selectedStartDate) { ($1, $0) }
            .map(Period.init)
            .bind(to: selectedPeriod)
            .disposed(by: disposeBag)

        let isSelectedPeriodChanged = selectedPeriod
            .map { $0 != periodStream.value }

        Observable
            .combineLatest(
                usecase.selectedStartDay,
                usecase.selectedEndDay
            )
            .map { $0 != nil && $1 != nil }
            .withLatestFrom(isSelectedPeriodChanged) {
                $0 && $1
            }
            .bind(to: saveButtonState)
            .disposed(by: disposeBag)
    }
}
