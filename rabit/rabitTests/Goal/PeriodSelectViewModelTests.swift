import XCTest
import RxSwift
import RxRelay
import RxTest
import Nimble
import RxNimble
@testable import rabit

class PeriodSelectViewModelTests: XCTestCase {
    
    private var sut: PeriodSelectViewModel!
    private var navigation: GoalNavigationMock!
    private var periodStream: BehaviorRelay<Period>!
    private var usecase: CalendarUsecaseMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        self.navigation = GoalNavigationMock()
        self.periodStream = .init(value: Period())
        self.usecase = CalendarUsecaseMock()
        
        self.sut = PeriodSelectViewModel(
            navigation: self.navigation,
            usecase: self.usecase,
            periodStream: self.periodStream
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testClosingViewRequested() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.closingViewRequested)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapClosePeriodSelectButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1),
                .next(20, 2)
            ]))
    }
    
    func testSaveButtonTouched() throws {
        // given
        let prevPeriodStreamValue = periodStream.value
        let newPeriodStreamValue = Period(start: Date(), end: Date())
        
        scheduler.createColdObservable([
            .next(0, newPeriodStreamValue)
        ])
        .bind(to: sut.selectedPeriod)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.periodStream)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevPeriodStreamValue),
                .next(10, newPeriodStreamValue)
            ]))
    }
    
    func testSelectedDate() throws {
        // given
        let newDate = Date(timeInterval: 36000, since: Date())
        let newCalendarDate = CalendarDate(
            date: newDate,
            number: "",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: sut.selectedDate)
        .disposed(by: disposeBag)
        
        // then
        scheduler.start()
        XCTAssertEqual(usecase.updateSelectedDateCallCount, 1)
        XCTAssertEqual(usecase.updateSelectedDataInputDate, newCalendarDate)
    }
    
    func testDeselectedDate() throws {
        // given
        let newDate = Date(timeInterval: 36000, since: Date())
        let newCalendarDate = CalendarDate(
            date: newDate,
            number: "",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: sut.deselectedDate)
        .disposed(by: disposeBag)
        
        // then
        scheduler.start()
        XCTAssertEqual(usecase.updateDeselectedDateCallCount, 1)
        XCTAssertEqual(usecase.updateDeselectedDateInputDate, newCalendarDate)
    }
    
    func test_UsecaseStartDateAndEndDate_WillChangeSelectedPeriod() throws {
        // given
        let newStartDate = Date(timeInterval: 36000, since: Date())
        let newEndDate = Date(timeInterval: 72000, since: Date())
        
        // when
        scheduler.createColdObservable([
            .next(10, newStartDate)
        ])
        .bind(to: usecase.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, newEndDate)
        ])
        .bind(to: usecase.endDate)
        .disposed(by: disposeBag)
        
        // then
        scheduler.start()
        XCTAssertNotEqual(sut.selectedPeriod.value.start, periodStream.value.start)
        XCTAssertEqual(sut.selectedPeriod.value.start, newStartDate)
        
        XCTAssertNotEqual(sut.selectedPeriod.value.end, periodStream.value.end)
        XCTAssertEqual(sut.selectedPeriod.value.end, newEndDate)
    }
}
