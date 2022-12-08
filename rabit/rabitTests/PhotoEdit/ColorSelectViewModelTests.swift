import XCTest
import RxRelay
import RxSwift
import RxTest
import Nimble
import RxNimble
@testable import rabit

class ColorSelectViewModelTests: XCTestCase {
    
    private var sut: ColorSelectViewModelProtocol!
    private var colorStream: BehaviorRelay<String>!
    private var navigation: ColorSelectNavigationMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        self.colorStream = .init(value: "")
        self.navigation = ColorSelectNavigationMock()
        
        self.sut = ColorSelectViewModel(
            colorStream: self.colorStream,
            navigation: self.navigation
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testSelectedColorWithSameColor() throws {
        // given
        let prevColor = colorStream.value
        
        // when
        scheduler.createColdObservable([
            .next(10, prevColor)
        ])
        .bind(to: sut.selectedColor)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonState)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, false),
                .next(10, false)
            ]))
    }
    
    func testSelectedColorWithDifferentColor() throws {
        // given
        let newColor = "#123123"
        
        scheduler.createColdObservable([
            .next(10, newColor)
        ])
        .bind(to: sut.selectedColor)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.saveButtonState)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, false),
                .next(10, true)
            ]))
    }
    
    func testCloseColorSelectRequest() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.closeColorSelectRequested)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseColorSelectButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
    }
    
    func testSaveButtonTouched() throws {
        // given
        let prevColor = self.colorStream.value
        let newColor = "#123123"
        
        scheduler.createColdObservable([
            .next(0, newColor)
        ])
        .bind(to: sut.selectedColor)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.colorStream)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevColor),
                .next(10, newColor)
            ]))
        XCTAssertEqual(self.colorStream.value, newColor)
    }
}
