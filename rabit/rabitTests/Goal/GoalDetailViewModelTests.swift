import XCTest
import RxSwift
import RxTest
import RxNimble
import Nimble
@testable import rabit

class GoalDetailViewModelTests: XCTestCase {
    
    private var sut: GoalDetailViewModel!
    private var navigation: GoalNavigationMock!
    private var initialGoal: Goal!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        
        self.navigation = GoalNavigationMock()
        self.initialGoal = Goal(
            title: "",
            subtitle: "",
            period: .init(),
            certTime: .init(),
            category: ""
        )
        
        self.sut = GoalDetailViewModel(
            navigation: self.navigation,
            goal: self.initialGoal
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
        expect(self.navigation.didTapCloseGoalDetailButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
    }
    
    func testShowPhotoCameraButton() {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.showCertPhotoCameraView)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCertPhotoCameraButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
    }
}
