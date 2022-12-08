import XCTest
import RxRelay
import RxSwift
import RxTest
import Nimble
import RxNimble
@testable import rabit

final class StyleSelectViewModelTests: XCTestCase {

    private var sut: StyleSelectViewModelProtocol!
    private var photoStream: BehaviorRelay<Album.Item>!
    private var navigation: StyleSelectNavigationMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.photoStream = .init(value: Photo())
        self.navigation = StyleSelectNavigationMock()
        
        self.sut = StyleSelectViewModel(
            photoStream: self.photoStream,
            navigation: self.navigation
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testAppliedPhotoWithSelectedStyleWithDifferentStyle() throws {
        // given
        let newStyle = Style.GillSans
        let prevPhoto = photoStream.value
        let photoAppliedNewStyle = Photo(
            categoryTitle: prevPhoto.categoryTitle,
            goalTitle: prevPhoto.goalTitle,
            imageName: prevPhoto.imageName,
            date: prevPhoto.date,
            color: prevPhoto.color,
            style: newStyle
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, photoAppliedNewStyle)
        ])
        .bind(to: sut.appliedPhotoWithSelectedStyle)
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
    
    func testAppliedPhotoWithSelectedStyleWithSameStyle() throws {
        // given
        let prevPhoto = photoStream.value
        
        // when
        scheduler.createColdObservable([
            .next(10, prevPhoto)
        ])
        .bind(to: sut.appliedPhotoWithSelectedStyle)
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
    
    func testCloseStyleSelectRequested() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.closeStyleSelectRequested)
        .disposed(by: disposeBag)
        
        
        // then
        expect(self.navigation.didTapCloseStyleSelectButtonSetCount)
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
        let prevPhoto = photoStream.value
        let newPhoto = Photo()

        scheduler.createColdObservable([
            .next(0, newPhoto)
        ])
        .bind(to: sut.appliedPhotoWithSelectedStyle)
        .disposed(by: disposeBag)
        
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.photoStream)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevPhoto),
                .next(10, newPhoto)
            ]))
    }
}
