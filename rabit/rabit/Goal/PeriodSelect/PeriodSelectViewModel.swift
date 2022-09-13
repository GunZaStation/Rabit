import Foundation
import RxSwift
import RxRelay

protocol PeriodSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol PeriodSelectViewModelOutput {
    
    var calendarData: BehaviorRelay<[CalendarDates]> { get }
    var selectedPeriod: BehaviorRelay<Period> { get }
    var selectedDate: PublishRelay<CalendarDate> { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
}

final class PeriodSelectViewModel: PeriodSelectViewModelInput, PeriodSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()

    let calendarData: BehaviorRelay<[CalendarDates]>
    let selectedPeriod: BehaviorRelay<Period>
    let selectedDate = PublishRelay<CalendarDate>()
    let saveButtonState = BehaviorRelay<Bool>(value: false)

    private let usecase: CalendarManagable

    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        usecase: CalendarManagable,
        with periodStream: BehaviorRelay<Period>
    ) {
        self.usecase = usecase
        self.calendarData = .init(value: usecase.dates)
        self.selectedPeriod = .init(value: periodStream.value)
        bind(to: navigation)
        bind(to: periodStream)
    }
}

private extension PeriodSelectViewModel {
    func bind(to navigation: GoalNavigation) {
        closingViewRequested
            .bind(to: navigation.closePeriodSelectView)
            .disposed(by: disposeBag)

        selectedDate
            .withUnretained(self)
            .bind { viewModel, selectedDay in
                viewModel.usecase.updateSelectedDate(with: selectedDay)
            }
            .disposed(by: disposeBag)

        let startDate = usecase.startDate.compactMap(\.?.date)
        let endDate = usecase.endDate.compactMap(\.?.date)

        Observable.combineLatest(
            startDate,
            endDate
        )
        .map(Period.init)
        .bind(to: selectedPeriod)
        .disposed(by: disposeBag)
    }

    func bind(to periodStream: BehaviorRelay<Period>) {
        saveButtonTouched
            .withLatestFrom(selectedPeriod)
            .bind(to: periodStream)
            .disposed(by: disposeBag)

        let isSelectedPeriodChanged = selectedPeriod
            .map { $0 != periodStream.value }

        Observable
            .combineLatest(
                usecase.startDate,
                usecase.endDate
            )
            .map { $0 != nil && $1 != nil }
            .withLatestFrom(isSelectedPeriodChanged) {
                $0 && $1
            }
            .bind(to: saveButtonState)
            .disposed(by: disposeBag)
    }
}
