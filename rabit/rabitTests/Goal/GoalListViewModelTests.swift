import XCTest
import RxRelay
import RxSwift
import RxTest
import Nimble
import RxNimble
@testable import rabit

final class GoalListViewModelTests: XCTestCase {
    
    private var sut: GoalListViewModelProtocol!
    private var repository: GoalListRepositoryMock!
    private var navigation: GoalNavigationMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        self.repository = GoalListRepositoryMock()
        self.navigation = GoalNavigationMock()
        
        self.sut = GoalListViewModel(
            repository: self.repository,
            navigation: self.navigation
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testRequestGoalList() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.requestGoalList)
        .disposed(by: disposeBag)
        
        // then
        scheduler.start()
        XCTAssertEqual(repository.fetchGoalListDataCallCount, 1)
    }
    
    func testCategoryAddButtonTouched() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.categoryAddButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCategoryAddButtonSetCount)
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
    
    func testGoalAddButtonTouched() throws {
        // given
        let category = Category(title: "")
        
        // when
        scheduler.createColdObservable([
            .next(10, category),
            .next(20, category)
        ])
        .bind(to: sut.goalAddButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapGoalAddButtonSetCount)
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
    
    func testShowGoalDetailViewTest() throws {
        // given
        let goal = Goal(
            title: "",
            subtitle: "",
            period: .init(),
            certTime: .init(),
            category: ""
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, goal)
        ])
        .bind(to: sut.showGoalDetailView)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapGoal)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, goal)
            ]))
    }
    
    func testRequestGoalListWillFetchGoalList() throws {
        // given
        let goal = Goal(
            title: "",
            subtitle: "",
            period: .init(),
            certTime: .init(),
            category: ""
        )
        let category = [
            Category(
                title: "",
                details: [goal],
                createdDate: Date()
            )
        ]
        
        self.repository.mockCategory = category
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.requestGoalList)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.goalList)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, category)
            ]))
    }
    
    func test_Navigation_DidTapCloseCategory_Trigger_GoalListViewModel_RequestGoalList() throws {
        // given
        let sut_requestGoalList_SetCount = BehaviorRelay<Int>(value: 0)
        
        sut.requestGoalList
            .map { _ in
                let prevValue = sut_requestGoalList_SetCount.value
                return prevValue + 1
            }
            .bind(to: sut_requestGoalList_SetCount)
            .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: navigation.didTapCloseCategoryAddButton)
        .disposed(by: disposeBag)
        
        // then
        expect(sut_requestGoalList_SetCount)
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
    
    func test_Navigation_DidTapCloseGoalAddViewButton_Trigger_GoalListViewModel_RequestGoalList() throws {
        // given
        let sut_requestGoalList_SetCount = BehaviorRelay<Int>(value: 0)
        
        sut.requestGoalList
            .map { _ in
                let prevValue = sut_requestGoalList_SetCount.value
                return prevValue + 1
            }
            .bind(to: sut_requestGoalList_SetCount)
            .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: navigation.didTapCloseGoalAddViewButton)
        .disposed(by: disposeBag)
        
        // then
        expect(sut_requestGoalList_SetCount)
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
}
