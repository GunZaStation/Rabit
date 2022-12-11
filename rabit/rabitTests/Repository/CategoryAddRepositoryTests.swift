import XCTest
import RxSwift
import RxTest
@testable import rabit

class CategoryAddRepositoryTests: XCTestCase {
    
    private var sut: CategoryAddRepository!
    private var realmManager: RealmManagerMock!
    
    private var categoryTitle: String!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        
        self.categoryTitle = "test_categoryTitle"
        
        self.realmManager = RealmManagerMock()
        self.realmManager.mockCategoryReadReturn = [
            Category(title: self.categoryTitle).toEntity()
        ]
        
        self.sut = CategoryAddRepository(realmManager: self.realmManager)
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testCheckTitleDuplicated_WhenSameTitleIsTyped() throws {
        // given
        let title: String = self.categoryTitle
        
        // when
        let result = sut.checkTitleDuplicated(input: title)
        
        // then
        XCTAssertEqual(result, true)
    }
    
    func testCheckTitleDuplicated_WhenDifferentTitleIsTyped() throws {
        // given
        let title = ""
        
        // when
        let result = sut.checkTitleDuplicated(input: title)
        
        // then
        XCTAssertEqual(result, false)
    }
    
    func testAddCategory_FailInWrite() throws {
        // given
        let category = Category(title: "test_categoryTitle")
        
        // when
        sut.addCategory(category)
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                
                case .success(let response):
                    XCTAssertEqual(response, false)
                    XCTAssertEqual(self?.realmManager.writeCallCount, 1)
                    XCTAssertEqual((self?.realmManager.writeEntity as? CategoryEntity)?.title, category.toEntity().title)
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testAddCategory_SuccessInWrite() throws {
        // given
        let category = Category(title: "test_categoryTitle")
        
        self.realmManager.writeShouldSuccess = true
        
        // when
        sut.addCategory(category)
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                
                case .success(let response):
                    XCTAssertEqual(response, true)
                    XCTAssertEqual(self?.realmManager.writeCallCount, 1)
                    XCTAssertEqual((self?.realmManager.writeEntity as? CategoryEntity)?.title, category.toEntity().title)
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
}
