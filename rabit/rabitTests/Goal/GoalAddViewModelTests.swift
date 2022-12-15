import XCTest
import RxSwift
import RxTest
import RxNimble
import Nimble
@testable import rabit

final class GoalAddViewModelTests: XCTestCase {
    
    private var sut: GoalAddViewModel!
    private var navigation: GoalNavigationMock!
    private var repository: GoalAddRepositoryMock!
    private var initialCategory: rabit.Category!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        
        self.navigation = GoalNavigationMock()
        self.repository = GoalAddRepositoryMock()
        self.initialCategory = Category(
            title: "test_category",
            details: [],
            createdDate: Date()
        )
        
        self.sut = GoalAddViewModel(
            navigation: self.navigation,
            category: self.initialCategory,
            repository: self.repository
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testCloseButtonTouched() {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.closeButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseGoalAddViewButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
    }
    
    func testPeriodFieldTouched() {
        // given
        scheduler.createColdObservable([
            .next(0, Period())
        ])
        .bind(to: sut.selectedPeriod)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.periodFieldTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapPeriodSelectTextField)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, sut.selectedPeriod)
            ]))
    }
    
    func testTimeFieldTouched() {
        // given
        scheduler.createColdObservable([
            .next(0, CertifiableTime())
        ])
        .bind(to: sut.selectedTime)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.timeFieldTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapTimeSelectTextField)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, sut.selectedTime)
            ]))
    }
    
    func testSaveButtonTouched() {
        // given
        let goalTitle = "test_goalTitle"
        let goalSubtitle = "test_goalSubTitle"
        let selectedPeriod = Period()
        let selectedTime = CertifiableTime()
        
        scheduler.createColdObservable([
            .next(0, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, goalSubtitle)
        ])
        .bind(to: sut.goalSubtitleInput)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, selectedPeriod)
        ])
        .bind(to: sut.selectedPeriod)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, selectedTime)
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
        expect(self.sut.goalAddResult)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, false)
            ]))
        
        XCTAssertEqual(repository.addGoalCallCount, 1)
        XCTAssertEqual(repository.addGoalInputGoal?.title, goalTitle)
        XCTAssertEqual(repository.addGoalInputGoal?.subtitle, goalSubtitle)
        XCTAssertEqual(repository.addGoalInputGoal?.period, selectedPeriod)
        XCTAssertEqual(repository.addGoalInputGoal?.certTime, selectedTime)
    }
    
    func testSaveButtonTouched_AndSuccessInAddGoalSaving() {
        // given
        let goalTitle = "test_goalTitle"
        let goalSubtitle = "test_goalSubTitle"
        let selectedPeriod = Period()
        let selectedTime = CertifiableTime()
        
        self.repository.mockAddGoalResult = true
        
        scheduler.createColdObservable([
            .next(0, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, goalSubtitle)
        ])
        .bind(to: sut.goalSubtitleInput)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, selectedPeriod)
        ])
        .bind(to: sut.selectedPeriod)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, selectedTime)
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
        expect(self.navigation.didTapCloseGoalAddViewButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
    }
    
    func testSaveButtonTouched_AndFailInAddGoalSaving() {
        // given
        let goalTitle = "test_goalTitle"
        let goalSubtitle = "test_goalSubTitle"
        let selectedPeriod = Period()
        let selectedTime = CertifiableTime()
        
        self.repository.mockAddGoalResult = false
        
        scheduler.createColdObservable([
            .next(0, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, goalSubtitle)
        ])
        .bind(to: sut.goalSubtitleInput)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, selectedPeriod)
        ])
        .bind(to: sut.selectedPeriod)
        .disposed(by: disposeBag)
        scheduler.createColdObservable([
            .next(0, selectedTime)
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
        expect(self.navigation.didTapCloseGoalAddViewButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0)
            ]))
    }
    
    func testGoalTitleInput_InTitleInputEmptyState_WhenTitleDuplicatedReturnFalse() {
        // given
        let goalTitle = ""
        self.repository.mockCheckTitleDuplicatedOutput = false
        
        // when
        scheduler.createColdObservable([
            .next(10, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonDisabled)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, true),
                .next(10, true)
            ]))
    }
    
    func testGoalTitleInput_InTitleInputNMotEmptyState_WhenTitleDuplicatedReturnFalse() {
        // given
        let goalTitle = "test_goalTitle"
        self.repository.mockCheckTitleDuplicatedOutput = false
        
        // when
        scheduler.createColdObservable([
            .next(10, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonDisabled)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, true),
                .next(10, false)
            ]))
    }
    
    func testGoalTitleInput_InTitleInputEmptyState_WhenTitleDuplicatedReturnTrue() {
        // given
        let goalTitle = ""
        self.repository.mockCheckTitleDuplicatedOutput = true
        
        // when
        scheduler.createColdObservable([
            .next(10, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonDisabled)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, true),
                .next(10, true)
            ]))
    }
    
    func testGoalTitleInput_InTitleInputNotEmptyState_WhenTitleDuplicatedReturnTrue() {
        // given
        let goalTitle = "test_goalTitle"
        self.repository.mockCheckTitleDuplicatedOutput = true
        
        // when
        scheduler.createColdObservable([
            .next(10, goalTitle)
        ])
        .bind(to: sut.goalTitleInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonDisabled)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, true),
                .next(10, true)
            ]))
    }
}
