import XCTest
import RxSwift
import RxRelay
import RxTest
import Nimble
import RxNimble
@testable import rabit

class CalendarUsecaseTests: XCTestCase {

    private var sut: CalendarUsecase!
    private var periodStream: BehaviorRelay<Period>!
    private var initialPeriod: Period!
    private var baseDate: Date!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        
        self.baseDate = DateComponents(calendar: .current, timeZone: .init(secondsFromGMT: 0), year: 2020, month: 01, day: 01).date!
        self.initialPeriod = Period(
            start: Date(),
            end: Date(timeInterval: 3600, since: Date())
        )
        self.periodStream = .init(value: self.initialPeriod)
        
        self.sut = CalendarUsecase(periodStream: self.periodStream, baseDate: self.baseDate)
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testUpdateSelectedDate_WhenTwoSameDatesDidSet_AndSelectLaterDate() throws {
        // given
        let dateEmitRelay = PublishRelay<CalendarDate>()
        
        dateEmitRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateSelectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let prevDate = Date()
        
        scheduler.createColdObservable([
            .next(0, prevDate)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, prevDate)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let newCalendarDate = CalendarDate(
            date: Date(timeInterval: 3600, since: prevDate),
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: dateEmitRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.endDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevDate),
                .next(10, newCalendarDate.date)
            ]))
    }
    
    func testUpdateSelectedDate_WhenTwoSameDatesDidSet_AndSelectEarlierDate() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateSelectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let prevDate = Date()
        
        scheduler.createColdObservable([
            .next(0, prevDate)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, prevDate)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let newCalendarDate = CalendarDate(
            date: Date(timeInterval: -3600, since: prevDate),
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.startDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevDate),
                .next(10, newCalendarDate.date)
            ]))
    }
    
    func testUpdateSelectedDate_WhenTwoDifferentDatesDidSet_AndSelectEarlierDateThanStartDate() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateSelectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let prevDate1 = Date()
        let prevDate2 = Date(timeInterval: 3600, since: prevDate1)
        
        scheduler.createColdObservable([
            .next(0, prevDate1)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, prevDate2)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let newCalendarDate = CalendarDate(
            date: Date(timeInterval: -3600, since: prevDate1),
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.startDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevDate1),
                .next(10, newCalendarDate.date)
            ]))
        
        expect(self.sut.endDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, prevDate1)
            ]))
    }
    
    func testUpdateSelectedDate_WhenTwoDifferentDatesDidSet_AndSelectLaterDateThanEndDate() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateSelectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let prevDate1 = Date()
        let prevDate2 = Date(timeInterval: 3600, since: prevDate1)
        
        scheduler.createColdObservable([
            .next(0, prevDate1)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, prevDate2)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let newCalendarDate = CalendarDate(
            date: Date(timeInterval: 3600, since: prevDate2),
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.endDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevDate2),
                .next(10, newCalendarDate.date)
            ]))
    }
    
    func testUpdateSelectedDate_WhenTwoDifferentDatesDidSet_AndSelectDateBetweenTwoDates() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateSelectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let prevDate1 = Date()
        let prevDate2 = Date(timeInterval: 3600, since: prevDate1)
        
        scheduler.createColdObservable([
            .next(0, prevDate1)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, prevDate2)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let newCalendarDate = CalendarDate(
            date: Date(timeInterval: 1800, since: prevDate1),
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.endDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevDate2),
                .next(10, newCalendarDate.date)
            ]))
    }
    
    func testUpdateSelectedDate_OneDateDidSet() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateSelectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let prevDate1: Date? = nil
        let prevDate2 = Date()
        
        scheduler.createColdObservable([
            .next(0, prevDate1)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, prevDate2)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let newCalendarDate = CalendarDate(
            date: Date(timeInterval: 1800, since: prevDate2),
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newCalendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.startDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevDate1),
                .next(10, newCalendarDate.date)
            ]))
        
        expect(self.sut.endDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, newCalendarDate.date)
            ]))
    }
    
    func testUpdateDeselectedDate_WhenTwoSameDatesDidSet() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateDeselectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let date = Date(timeInterval: 3600, since: Date())
        
        scheduler.createColdObservable([
            .next(0, date)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(0, date)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let calendarDate = CalendarDate(
            date: date,
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, calendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.startDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, date),
                .next(10, nil)
            ]))
        
        expect(self.sut.endDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, nil)
            ]))
    }
    
    func testUpdateDeselectedDate_WhenOneDateDidSet() throws {
        // given
        let emittingDateRelay = PublishRelay<CalendarDate>()
        
        emittingDateRelay
            .withUnretained(self)
            .bind { testClass, value in
                testClass.sut.updateDeselectedDate(with: value)
            }
            .disposed(by: disposeBag)
        
        let startDate = Date(timeInterval: 3600, since: Date())
        let endDate = Date(timeInterval: 7200, since: Date())
        
        scheduler.createColdObservable([
            .next(0, startDate)
        ])
        .bind(to: sut.startDate)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, endDate)
        ])
        .bind(to: sut.endDate)
        .disposed(by: disposeBag)
        
        let calendarDate = CalendarDate(
            date: startDate,
            number: "1",
            isWithinDisplayedMonth: false,
            isBeforeToday: false
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, calendarDate)
        ])
        .bind(to: emittingDateRelay)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.startDate)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, startDate),
                .next(10, endDate)
            ]))
    }
    
    func testDates() throws {
        // when
        let countDatesIn2020_01_Calendar = sut.dates.first!.items.count
        
        // then
        // 2020년 1월 1일 달력에는 2019.12.29 ~ 2020.02.01 총 34개의 날짜가 표시됨.
        XCTAssertEqual(countDatesIn2020_01_Calendar, 34)
    }
}
