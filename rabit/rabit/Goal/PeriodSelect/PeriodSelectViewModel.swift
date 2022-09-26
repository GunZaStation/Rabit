import Foundation
import RxSwift
import RxRelay

protocol PeriodSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var selectedDate: PublishRelay<CalendarDates.Item> { get }
    var deselectedDate: PublishRelay<CalendarDates.Item> { get }
    var prevMonthButtonTouched: PublishRelay<Void> { get }
    var nextMonthButtonTouched: PublishRelay<Void> { get }
}

protocol PeriodSelectViewModelOutput {
    
    var calendarData: BehaviorRelay<[CalendarDates]> { get }
    var selectedPeriod: BehaviorRelay<Period> { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
    var prevMonthButtonState: BehaviorRelay<Bool> { get }
    var nextMonthButtonState: BehaviorRelay<Bool> { get }
}

protocol PeriodSelectViewModelProtocol: PeriodSelectViewModelInput, PeriodSelectViewModelOutput { }

final class PeriodSelectViewModel: PeriodSelectViewModelProtocol {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedDate = PublishRelay<CalendarDates.Item>()
    let deselectedDate = PublishRelay<CalendarDates.Item>()
    let prevMonthButtonTouched = PublishRelay<Void>()
    let nextMonthButtonTouched = PublishRelay<Void>()

    let calendarData: BehaviorRelay<[CalendarDates]>
    let selectedPeriod: BehaviorRelay<Period>
    let saveButtonState = BehaviorRelay<Bool>(value: true)
    let prevMonthButtonState = BehaviorRelay<Bool>(value: false)
    let nextMonthButtonState = BehaviorRelay<Bool>(value: true)

    private let usecase: CalendarUsecaseProtocol

    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        usecase: CalendarUsecaseProtocol,
        periodStream: BehaviorRelay<Period>
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
            .bind { viewModel, selectedDate in
                viewModel.usecase.updateSelectedDate(with: selectedDate)
            }
            .disposed(by: disposeBag)

        deselectedDate
            .withUnretained(self)
            .bind { viewModel, deselectedDate in
                viewModel.usecase.updateDeselectedDate(with: deselectedDate)
            }
            .disposed(by: disposeBag)

        let startDate = usecase.startDate.compactMap { $0 }
        let endDate = usecase.endDate.compactMap { $0 }

        Observable.combineLatest(
            startDate,
            endDate
        )
        .map(Period.init)
        .bind(to: selectedPeriod)
        .disposed(by: disposeBag)

        Observable.combineLatest(
            usecase.startDate,
            usecase.endDate
        )
        .map { $0 != nil && $1 != nil }
        .bind(to: saveButtonState)
        .disposed(by: disposeBag)
    }

    func bind(to periodStream: BehaviorRelay<Period>) {
        saveButtonTouched
            .withLatestFrom(selectedPeriod)
            .bind(to: periodStream)
            .disposed(by: disposeBag)
    }
}
