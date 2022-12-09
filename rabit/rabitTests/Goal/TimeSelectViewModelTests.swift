import XCTest
import RxSwift
import RxRelay
import RxTest
import Nimble
import RxNimble
@testable import rabit

class TimeSelectViewModelTests: XCTestCase {

    private var sut: TimeSelectViewModel!
    private var navigation: GoalNavigationMock!
    private var timeStream: BehaviorRelay<CertifiableTime>!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        
        self.navigation = GoalNavigationMock()
        self.timeStream = .init(value: .init())
        
        self.sut = TimeSelectViewModel(
            navigation: self.navigation,
            with: self.timeStream
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
        expect(self.navigation.didTapCloseTimeSelectButtonSetCount)
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
        let prevTime = timeStream.value
        let newTime = CertifiableTime()
        
        scheduler.createColdObservable([
            .next(0, newTime)
        ])
        .bind(to: sut.selectedTime)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.timeStream)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevTime),
                .next(10, newTime)
            ]))
    }
    
    func testViewDidLoad_WillChangeSelectedStartTime() throws {
        // given
        let newStartDate = Date(timeInterval: 36000, since: Date())
        let newEndDate = Date(timeInterval: 72000, since: Date())
        let newTimeStreamValue = CertifiableTime(start: newStartDate, end: newEndDate)
        
        scheduler.createColdObservable([
            .next(0, newTimeStreamValue)
        ])
        .bind(to: timeStream)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.viewDidLoad)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.selectedStartTime)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, Double(newTimeStreamValue.start.toSeconds()))
            ]))
    }
    
    func testViewDidLoad_WillChangeSelectedEndTime() throws {
        let newStartDate = Date(timeInterval: 36000, since: Date())
        let newEndDate = Date(timeInterval: 72000, since: Date())
        let newTimeStreamValue = CertifiableTime(start: newStartDate, end: newEndDate)
        
        scheduler.createColdObservable([
            .next(0, newTimeStreamValue)
        ])
        .bind(to: timeStream)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.viewDidLoad)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.selectedEndTime)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, Double(newTimeStreamValue.end.toSeconds()))
            ]))
    }
    
    func testSelectedStartTimeAndSelectedEndTimeAndSelectedDays() throws {
        // given
        let prevSelectedTimeValue = sut.selectedTime.value
        let newStartTime = 10.0
        let newEndTime = 11.0
        let newDays: Set<Day> = .init([Day(rawValue: 0)!])
        
        // when
        scheduler.createColdObservable([
            .next(10, newStartTime)
        ])
        .bind(to: sut.selectedStartTime)
        .disposed(by: disposeBag)

        scheduler.createColdObservable([
            .next(10, newEndTime)
        ])
        .bind(to: sut.selectedEndTime)
        .disposed(by: disposeBag)

        scheduler.createColdObservable([
            .next(10, newDays)
        ])
        .bind(to: sut.selectedDays)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.selectedTime)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevSelectedTimeValue),
                .next(10, CertifiableTime(start: Int(newStartTime), end: Int(newEndTime), days: prevSelectedTimeValue.days)),
                .next(10, CertifiableTime(start: Int(newStartTime), end: Int(newEndTime), days: Days(newDays)))
            ]))
    }
    
    func testSelectedDays_InNotEmptyState() throws {
        // given
        let newDays: Set<Day> = .init([Day(rawValue: 0)!])
        
        // when
        scheduler.createColdObservable([
            .next(10, newDays)
        ])
        .bind(to: sut.selectedDays)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonEnabled)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, true)
            ]))
    }
    
    func testSelectedDays_InEmptyState() throws {
        // given
        let newDays: Set<Day> = .init()
        
        // when
        scheduler.createColdObservable([
            .next(10, newDays)
        ])
        .bind(to: sut.selectedDays)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonEnabled)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, false)
            ]))
    }
}
