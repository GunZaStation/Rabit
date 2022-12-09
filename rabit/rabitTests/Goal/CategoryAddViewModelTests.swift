import XCTest
import RxSwift
import RxTest
import Nimble
import RxNimble
@testable import rabit

class CategoryAddViewModelTests: XCTestCase {

    private var sut: CategoryAddViewModel!
    private var repository: CategoryAddRepositoryMock!
    private var navigation: GoalNavigationMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        
        self.repository = CategoryAddRepositoryMock()
        self.navigation = GoalNavigationMock()
        
        self.sut = CategoryAddViewModel(
            navigation: self.navigation,
            repository: self.repository
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testCategoryTitleInput_InTitleInputEmptyState_WhenTitleDuplicatedReturnFalse() throws {
        // given
        let categoryTitle = ""
        self.repository.mockCheckTitleDuplicatedOutput = false
        
        // when
        scheduler.createColdObservable([
            .next(10, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
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
    
    func testCategoryTitleInput_InTitleInputNotEmptyState_WhenTitleDuplicatedReturnFalse() throws {
        // given
        let categoryTitle = "test_CategoryTitle"
        self.repository.mockCheckTitleDuplicatedOutput = false
        
        // when
        scheduler.createColdObservable([
            .next(10, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
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
    
    func testCategoryTitleInput_InTitleInputEmptyState_WhenTitleDuplicatedReturnTrue() throws {
        // given
        let categoryTitle = ""
        self.repository.mockCheckTitleDuplicatedOutput = true
        
        // when
        scheduler.createColdObservable([
            .next(10, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
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
    
    func testCategoryTitleInput_InTitleInputNotEmptyState_WhenTitleDuplicatedReturnTrue() throws {
        // given
        let categoryTitle = "test_CategoryTitle"
        self.repository.mockCheckTitleDuplicatedOutput = true
        
        // when
        scheduler.createColdObservable([
            .next(10, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
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
    
    func testCategoryTitleInput_WhenTitleDuplicatedReturnFalse() throws {
        // given
        let categoryTitle = "test_CategoryTitle"
        self.repository.mockCheckTitleDuplicatedOutput = false
        
        // when
        scheduler.createColdObservable([
            .next(10, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.warningLabelHidden)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, true)
            ]))
    }
    
    func testCategoryTitleInput_WhenTitleDuplicatedReturnTrue() throws {
        // given
        let categoryTitle = "test_CategoryTitle"
        self.repository.mockCheckTitleDuplicatedOutput = true
        
        // when
        scheduler.createColdObservable([
            .next(10, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.warningLabelHidden)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, false)
            ]))
    }
    
    func testSaveButtonTouched() throws {
        // given
        let categoryTitle = "test_CategoryTitle"

        scheduler.createColdObservable([
            .next(0, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        scheduler.start()
        XCTAssertEqual(self.repository.addCategoryCallCount, 1)
        XCTAssertEqual(self.repository.addCategoryInputCategory?.title, categoryTitle)
    }
    
    func testCloseButtonTouched() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.closeButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseCategoryAddButtonSetCount)
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
    
    func testCategoryAddResult_WhenIsTrue() throws {
        // when
        scheduler.createColdObservable([
            .next(10, true),
            .next(20, true)
        ])
        .bind(to: sut.categoryAddResult)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseCategoryAddButtonSetCount)
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
    
    func testCategoryAddResult_WhenIsFalse() throws {
        // when
        scheduler.createColdObservable([
            .next(10, false),
            .next(20, false)
        ])
        .bind(to: sut.categoryAddResult)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseCategoryAddButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0)
            ]))
    }
    
    func testSaveButtonTouched_AndSuccessInAddCategorySaving() throws {
        // given
        let categoryTitle = "test_CategoryTitle"
        self.repository.mockAddCategoryResult = true
        
        scheduler.createColdObservable([
            .next(0, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseCategoryAddButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
        
        XCTAssertEqual(self.repository.addCategoryCallCount, 1)
        XCTAssertEqual(self.repository.addCategoryInputCategory?.title, categoryTitle)
    }
    
    func testSaveButtonTouched_AndFailInAddCategorySaving() throws {
        // given
        let categoryTitle = "test_CategoryTitle"
        self.repository.mockAddCategoryResult = false
        
        scheduler.createColdObservable([
            .next(0, categoryTitle)
        ])
        .bind(to: sut.categoryTitleInput)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseCategoryAddButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0)
            ]))
        
        XCTAssertEqual(self.repository.addCategoryCallCount, 1)
        XCTAssertEqual(self.repository.addCategoryInputCategory?.title, categoryTitle)
    }
}
