import XCTest
import RxSwift
import RxRelay
import RxTest
import Nimble
import RxNimble
@testable import rabit

class CertPhotoCameraViewModelTests: XCTestCase {
    
    private var sut: CertPhotoCameraViewModel!
    private var navigation: GoalNavigationMock!
    private var repository: AlbumRepositoryMock!
    private var mockGoal: Goal!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        
        self.navigation = GoalNavigationMock()
        self.repository = AlbumRepositoryMock()
        self.mockGoal = Goal(
            title: "",
            subtitle: "",
            period: .init(),
            certTime: .init(),
            category: ""
        )
        
        self.sut = CertPhotoCameraViewModel(
            navigation: self.navigation,
            goal: self.mockGoal,
            repository: self.repository
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    func testCertPhotoDataInput() throws {
        // given
        let newData = Data()
        
        // when
        scheduler.createColdObservable([
            .next(10, newData)
        ])
        .bind(to: sut.certPhotoDataInput)
        .disposed(by: disposeBag)
        
        // then
        expect(self.sut.previewPhotoData)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(10, newData)
            ]))
    }
    
    func testNextButtonTouched_WillCallRepositorySavePhotoImageDataMethod() throws {
        // given
        let newData = Data()
        let currentDateInfo = "\(Date().description.prefix(19).replacingOccurrences(of: " ", with: "_")).png"
        
        scheduler.createColdObservable([
            .next(0, newData)
        ])
        .bind(to: sut.previewPhotoData)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.nextButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        scheduler.start()
        XCTAssertEqual(repository.savePhotoImageDataCallCount, 1)
        XCTAssertEqual(repository.savePhotoImageDataName, currentDateInfo)
    }
    
    func testNextButtonTouched_WhenRepositoryReturnFailureResult() throws {
        // given
        repository.mockSavePhotoImageResult = false
        let newData = Data()
        
        scheduler.createColdObservable([
            .next(0, newData)
        ])
        .bind(to: sut.previewPhotoData)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.nextButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTakeCertPhotoSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0)
            ]))
    }
    
    func testNextButtonTouched_WhenRepositoryReturnSuccessResult() throws {
        // given
        repository.mockSavePhotoImageResult = true
        let newData = Data()
        
        scheduler.createColdObservable([
            .next(0, newData)
        ])
        .bind(to: sut.previewPhotoData)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, ()),
            .next(20, ())
        ])
        .bind(to: sut.nextButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTakeCertPhotoSetCount)
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
    
    func testCloseButtonTouched() {
        // when
        scheduler.createColdObservable([
            .next(10, ())
        ])
        .bind(to: sut.closeButtonTouched)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTapCloseCertPhotoCameraButtonSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0),
                .next(10, 1)
            ]))
    }
    
    func testPhotoSaveResultGotSuccess() throws {
        // given
        let newData = Data()

        scheduler.createColdObservable([
            .next(0, newData)
        ])
        .bind(to: sut.previewPhotoData)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, true),
            .next(20, true)
        ])
        .bind(to: sut.photoSaveResult)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTakeCertPhotoSetCount)
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
    
    func testPhotoSaveResultGotFailure() throws {
        // given
        let newData = Data()
        
        scheduler.createColdObservable([
            .next(0, newData)
        ])
        .bind(to: sut.previewPhotoData)
        .disposed(by: disposeBag)
        
        // when
        scheduler.createColdObservable([
            .next(10, false),
            .next(20, false)
        ])
        .bind(to: sut.photoSaveResult)
        .disposed(by: disposeBag)
        
        // then
        expect(self.navigation.didTakeCertPhotoSetCount)
            .events(
                scheduler: self.scheduler,
                disposeBag: self.disposeBag
            )
            .to(equal([
                .next(0, 0)
            ]))
    }
}
