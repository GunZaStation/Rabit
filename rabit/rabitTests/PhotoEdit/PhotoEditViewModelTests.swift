import XCTest
import RxRelay
import RxSwift
import Nimble
import RxNimble
import RxTest
@testable import rabit

final class PhotoEditViewModelTests: XCTestCase {
    
    private var sut: PhotoEditViewModelProtocol!
    private var photoStream: BehaviorRelay<Photo>!
    private var repository: AlbumRepositoryMock!
    private var navigation: PhotoEditNavigationMock!
    
    private var prevPhoto: Photo!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        self.repository = AlbumRepositoryMock()
        self.navigation = PhotoEditNavigationMock()
        self.prevPhoto = Photo(categoryTitle: "", goalTitle: "", imageName: "", date: Date(), color: "", style: .none)
        self.photoStream = .init(value: self.prevPhoto)
        
        self.sut = PhotoEditViewModel(
            photoStream: self.photoStream,
            repository: self.repository,
            photoEditMode: .edit,
            navigation: self.navigation
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testSelectColorButtonTouched() throws {
        // given
        let hexPhotoColor = "test"

        scheduler.createColdObservable([
            .next(0, hexPhotoColor)
        ])
        .bind(to: sut.hexPhotoColor)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.selectColorButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapSelectColorButton)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, self.sut.hexPhotoColor)
            ]))
    }
    
    func testSelectStyleButtonTouched() throws {
        // given
        let photo = Photo(
            categoryTitle: "",
            goalTitle: "",
            imageName: "",
            date: Date(),
            color: "",
            style: .none
        )
        
        scheduler.createColdObservable([
            .next(0, photo)
        ])
        .bind(to: sut.selectedPhotoData)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.selectStyleButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapSelectStyleButton)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, self.sut.selectedPhotoData)
            ]))
    }
    
    func testBackButtonTouched() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.backButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapBackButtonSetCount)
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
    
    func testSaveButtonTouchedGotSuccessInAlbumUpdate() throws {
        // given
        self.repository.mockUpdateResult = true

        let photo = Photo(
            categoryTitle: "",
            goalTitle: "",
            imageName: "",
            date: Date(),
            color: "",
            style: .none
        )

        scheduler.createColdObservable([
            .next(0, photo)
        ])
        .bind(to: sut.selectedPhotoData)
        .disposed(by: disposeBag)

        // when
        self.scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)

        // then
        expect(self.sut.albumUpdateResult)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, true)
            ]))

        expect(self.photoStream)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, photo)
            ]))
        
        expect(self.navigation.didChangePhotoSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, 1)
            ]))

        XCTAssertEqual(repository.updateAlbumDataCallCount, 1)
        XCTAssertEqual(repository.updateAlbumData, photo)
    }
    
    func testSaveButtonTouchedGotFailureInAlbumUpdate() throws {
        // given
        self.repository.mockUpdateResult = false

        let photo = Photo(
            categoryTitle: "",
            goalTitle: "",
            imageName: "",
            date: Date(),
            color: "",
            style: .none
        )

        scheduler.createColdObservable([
            .next(0, photo)
        ])
        .bind(to: sut.selectedPhotoData)
        .disposed(by: disposeBag)

        // when
        self.scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.saveButtonTouched)
        .disposed(by: disposeBag)

        // then
        expect(self.sut.albumUpdateResult)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, false)
            ]))

        expect(self.photoStream)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, photo)
            ]))

        expect(self.navigation.didChangePhotoSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, 0)
            ]))
        XCTAssertEqual(repository.updateAlbumDataCallCount, 1)
        XCTAssertEqual(repository.updateAlbumData, photo)
    }
    
    func testHexPhotoColor() throws {
        // given
        let photo = Photo(
            categoryTitle: "",
            goalTitle: "",
            imageName: "",
            date: Date(),
            color: "",
            style: .none
        )
        
        scheduler.createColdObservable([
            .next(0, photo)
        ])
        .bind(to: sut.selectedPhotoData)
        .disposed(by: disposeBag)
        
        let newHexPhotoColor = "#123123"
        
        let newPhotoData = Photo(
            uuid: photo.uuid,
            categoryTitle: photo.categoryTitle,
            goalTitle: photo.goalTitle,
            imageName: photo.imageName,
            date: photo.date,
            color: newHexPhotoColor,
            style: photo.style,
            imageData: photo.imageData
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, newHexPhotoColor)
        ])
        .bind(to: sut.hexPhotoColor)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.selectedPhotoData)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, photo),
                .next(10, newPhotoData)
            ]))
    }
    
    func testAlbumUpdateResultGotSuccess() throws {
        // when
        scheduler.createColdObservable([
            .next(10, true),
            .next(20, true)
        ])
        .bind(to: sut.albumUpdateResult)
        .disposed(by: disposeBag)

        // then
        expect(self.navigation.didChangePhotoSetCount)
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
    
    func testAlbumUpdateResultGotFailure() throws {
        // when
        scheduler.createColdObservable([
            .next(10, false)
        ])
        .bind(to: sut.albumUpdateResult)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didChangePhotoSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0)
            ]))
    }
    
    func testSelectedPhotoDataInEditModeWithDifferentPhotoData() throws {
        // when
        scheduler.createColdObservable([
            .next(10, Photo())
        ])
        .bind(to: sut.selectedPhotoData)
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
    
    func testSelectedPhotoDataInEditModeWithSamePhotoData() throws {
        // when
        scheduler.createColdObservable([
            .next(10, self.prevPhoto)
        ])
        .bind(to: sut.selectedPhotoData)
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
    
    func testSelectedPhotoDataInAddModeWithSamePhotoData() throws {
        // given
        let sut = PhotoEditViewModel(
            photoStream: self.photoStream,
            repository: self.repository,
            photoEditMode: .add,
            navigation: self.navigation
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, self.prevPhoto)
        ])
        .bind(to: sut.selectedPhotoData)
        .disposed(by: disposeBag)
        
        // then
        expect(sut.saveButtonState)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, true),
                .next(10, true)
            ]))
    }
    
    func testSelectedPhotoDataInAddModeWithDifferentPhotoData() throws {
        // given
        let sut = PhotoEditViewModel(
            photoStream: self.photoStream,
            repository: self.repository,
            photoEditMode: .add,
            navigation: self.navigation
        )
        
        // when
        scheduler.createColdObservable([
            .next(10, Photo())
        ])
        .bind(to: sut.selectedPhotoData)
        .disposed(by: disposeBag)
        
        // then
        expect(sut.saveButtonState)
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
