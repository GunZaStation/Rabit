import XCTest
import RxSwift
import RxRelay
@testable import rabit
import RxTest
import RxNimble
import Nimble

final class AlbumViewModelTests: XCTestCase {
    
    private var sut: AlbumViewModelProtocol!
    private var repository: AlbumRepositoryMock!
    private var navigation: AlbumNavigationMock!
    
    private var scheduler: TestScheduler!
    
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.scheduler = .init(initialClock: 0)
        self.repository = AlbumRepositoryMock()
        self.navigation = AlbumNavigationMock()


        self.sut = AlbumViewModel(
            repository: self.repository,
            navigation: self.navigation
        )
    }

    func testRequestAlbumData() throws {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.requestAlbumData)
        .disposed(by: disposeBag)
        
        // then
        
        scheduler.start()
        XCTAssertEqual(repository.fetchAlbumDataCallCount, 1)
    }
    
    func testShowNextViewRequest() throws {
        // when
        self.scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: self.sut.showNextViewRequested)
        .disposed(by: self.disposeBag)
        
        // then
        expect(self.navigation.didSelectPhoto)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, sut.photoSelected)
            ]))
    }
    
    func testRequstAlbumDataWillFetchAlbumData() throws {
        // given
        let prevAlbum = sut.albumData.value
        
        let photo = Photo(
            categoryTitle: "",
            goalTitle: "",
            imageName: "",
            date: Date(),
            color: "",
            style: .none
        )
        let album = [
            Album(categoryTitle: "", items: [
                photo
            ])
        ]
        
        self.repository.mockAlbum = album
        
        // when
        self.scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.requestAlbumData)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.albumData)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevAlbum),
                .next(10, album)
            ]))
    }
    
    func testCameBackWithChangedPhoto() throws {
        // given
        let photo = Photo()
        scheduler.createColdObservable([
            .next(0, photo)
        ])
        .bind(to: sut.photoSelected)
        .disposed(by: disposeBag)
        
        let index = IndexPath(item: 0, section: 0)
        scheduler.createColdObservable([
            .next(0, index)
        ])
        .bind(to: sut.indexSelected)
        .disposed(by: disposeBag)
        
        let prevAlbum = [
            Album(categoryTitle: "", items: [
                Photo()
            ])
        ]
        
        scheduler.createColdObservable([
            .next(0, prevAlbum)
        ])
        .bind(to: sut.albumData)
        .disposed(by: disposeBag)

        let newAlbumExpected = [
            Album(categoryTitle: "", items: [photo])
        ]
        
        // when
        self.scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: navigation.didChangePhoto)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.albumData)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, prevAlbum),
                .next(10, newAlbumExpected)
            ]))
    }
}
