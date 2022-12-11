import XCTest
import RxSwift
import RxTest
@testable import rabit

class GoalListRepositoryTests: XCTestCase {
    
    private var sut: GoalListRepository!
    private var realmManager: RealmManagerMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        self.realmManager = RealmManagerMock()
        self.sut = GoalListRepository(realmManager: self.realmManager)
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testFetchGoalListData_WhenCategoryEntitiesNotExist() throws {
        // when
        sut.fetchGoalListData()
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, [])
                    XCTAssertEqual(self?.realmManager.readCallCount, 2)
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testFetchGoalListData_WhenCategoryEntitiesAndGoalEntitiesExist() throws {
        // given
        let goals_1 = [
            Goal(
                title: "",
                subtitle: "",
                period: .init(),
                certTime: .init(),
                category: "test1"
            ),
            Goal(
                title: "",
                subtitle: "",
                period: .init(),
                certTime: .init(),
                category: "test1"
            )
        ]
        let goals_2 = [
            Goal(
                title: "",
                subtitle: "",
                period: .init(),
                certTime: .init(),
                category: "test2"
            ),
            Goal(
                title: "",
                subtitle: "",
                period: .init(),
                certTime: .init(),
                category: "test2"
            )
        ]
        let categories = [
            Category(
                title: "test1",
                details: goals_1,
                createdDate: Date()
            ),
            Category(
                title: "test2",
                details: goals_2,
                createdDate: Date(timeInterval: 3600, since: Date())
            )
        ]
        
        let categoryEntities = categories.map { $0.toEntity() }
        let goalEntities = (goals_1 + goals_2).map { $0.toEntity() }
        
        self.realmManager.mockCategoryReadReturn = categoryEntities
        self.realmManager.mockGoalReadReturn = goalEntities
        
        // when
        sut.fetchGoalListData()
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, categories)
                    XCTAssertEqual(self?.realmManager.readCallCount, 6)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
}
