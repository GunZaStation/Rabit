import XCTest
import RxSwift
import RxTest
@testable import rabit

class GoalAddRepositoryTests: XCTestCase {
    
    private var sut: GoalAddRepository!
    private var realmManager: RealmManagerMock!
    
    private var categoryTitle: String!
    private var goalTitle: String!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        
        self.categoryTitle = "test_categoryTitle"
        self.goalTitle = "test_goalTitle"
        
        self.realmManager = RealmManagerMock()
        self.realmManager.mockGoalReadReturn = [
            Goal(
                title: self.goalTitle,
                subtitle: "",
                period: .init(),
                certTime: .init(),
                category: self.categoryTitle
            ).toEntity()
        ]
        
        self.sut = GoalAddRepository(
            category: Category(title: self.categoryTitle),
            realmManager: self.realmManager
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testCheckTitlePulicated_WhenSameTitleIsTyped() throws {
        // given
        let title: String = self.goalTitle
        
        // when
        let result = sut.checkTitleDuplicated(title: title)
        
        // then
        XCTAssertEqual(result, true)
    }
    
    func testCheckTitlePulicated_WhenDifferentTitleIsTyped() throws {
        // given
        let title = ""
        
        // when
        let result = sut.checkTitleDuplicated(title: title)
        
        // then
        XCTAssertEqual(result, false)
    }
    
    func testAddGoal_FailInWrite() throws {
        // given
        let goal = Goal(
            title: "test_goalTitle",
            subtitle: "",
            period: .init(),
            certTime: .init(),
            category: ""
        )
        
        // when
        sut.addGoal(goal)
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then 
                switch events {
                
                case .success(let response):
                    XCTAssertEqual(response, false)
                    XCTAssertEqual(self?.realmManager.writeCallCount, 1)
                    XCTAssertEqual((self?.realmManager.writeEntity as? GoalEntity)?.title, goal.toEntity().title)
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testAddGoal_SuccessInWrite() throws {
        // given
        let goal = Goal(
            title: "test_goalTitle",
            subtitle: "",
            period: .init(),
            certTime: .init(),
            category: ""
        )
        
        self.realmManager.writeShouldSuccess = true
        
        // when
        sut.addGoal(goal)
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                
                case .success(let response):
                    XCTAssertEqual(response, true)
                    XCTAssertEqual(self?.realmManager.writeCallCount, 1)
                    XCTAssertEqual((self?.realmManager.writeEntity as? GoalEntity)?.title, goal.toEntity().title)
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
}
