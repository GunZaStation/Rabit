import XCTest
import RealmSwift
import RxSwift
import RxTest
@testable import rabit

final class AlbumRepositoryTests: XCTestCase {

    private var sut: AlbumRepository!
    private var realmManager: RealmManagerMock!
    private var fileManager: FileManagerMock!
    
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.realmManager = RealmManagerMock()
        self.fileManager = FileManagerMock()
        
        self.sut = AlbumRepository(
            realmManager: self.realmManager,
            fileManager: self.fileManager
        )
        
        self.scheduler = .init(initialClock: 0)
        self.disposeBag = DisposeBag()
    }

    func testFetchAlbumData_WhenCategoryEntitiesNotExist() throws {
        // when
        sut.fetchAlbumData()
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, [])
                    XCTAssertEqual(self?.realmManager.readCallCount, 1)
                
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testFetchAlbumData_WhenCategoryEntitiesAndPhotoEntitiesExist() throws {
        // given
        let categoryEntities = [Category(title: "test").toEntity()]
        let photo = [
            Photo(
                categoryTitle: "test",
                goalTitle: "",
                imageName: "",
                date: Date(),
                color: "",
                style: .none
            ),
            Photo(
                categoryTitle: "test",
                goalTitle: "",
                imageName: "",
                date: Date(),
                color: "",
                style: .none
            )
        ]
        let album = [
            Album(categoryTitle: "test", items: photo)
        ]
        
        self.realmManager.mockCategoryReadReturn = categoryEntities
        self.realmManager.mockPhotoReadRetrun = photo.map { $0.toEntity() }
        
        // when
        sut.fetchAlbumData()
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, album)
                    XCTAssertEqual(self?.realmManager.readCallCount, 2)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testFetchAlbumData_WhenCategoryEntitiesExist_AndPhotoNotEntities() throws {
        // given
        let categoryEntities = [Category(title: "test").toEntity()]
        
        self.realmManager.mockCategoryReadReturn = categoryEntities

        // when
        sut.fetchAlbumData()
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
    
    func testUpdateAlbumData_FailInUpdate() throws {
        // when
        sut.updateAlbumData(Photo())
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, false)
                    XCTAssertEqual(self?.realmManager.updateCallCount, 1)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testUpdateAlbumData_SuccessInUpdate() throws {
        // given
        self.realmManager.updateShouldSuccess = true
        
        // when
        sut.updateAlbumData(Photo())
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, true)
                    XCTAssertEqual(self?.realmManager.updateCallCount, 1)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testSavePhotoImageData_WhenDocumentDirectoryExists_AndSameFileExists() throws {
        // given
        self.fileManager.mockURLsResult = [URL(string: "https://www.sol.com")!]
        self.fileManager.mockFileExistsResult = true
        
        // when
        sut.savePhotoImageData(Data(), name: "")
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, false)
                    XCTAssertEqual(self?.fileManager.urlsCallCount, 1)
                    XCTAssertEqual(self?.fileManager.fileExistsCallCount, 1)
                    XCTAssertEqual(self?.fileManager.removeItemCallCount, 1)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testSavePhotoImageData_WhenDocumentDirectoryExists_AndSameFileNotExists() throws {
        // given
        self.fileManager.mockURLsResult = [URL(string: "https://www.sol.com")!]
        self.fileManager.mockFileExistsResult = false
        
        // when
        sut.savePhotoImageData(Data(), name: "")
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in
                
                // then
                switch events {
                    
                case .success(let response):
                    XCTAssertEqual(response, false)
                    XCTAssertEqual(self?.fileManager.urlsCallCount, 1)
                    XCTAssertEqual(self?.fileManager.fileExistsCallCount, 1)
                    XCTAssertEqual(self?.fileManager.removeItemCallCount, 0)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
    
    func testSavePhotoImageData_WhenDocumentDirectoryNotExists() throws {
        // when
        sut.savePhotoImageData(Data(), name: "")
            .subscribe(on: self.scheduler)
            .subscribe { [weak self] events in

                //then
                switch events {
                
                case .success(let response):
                    XCTAssertEqual(response, false)
                    XCTAssertEqual(self?.fileManager.urlsCallCount, 1)
                    XCTAssertEqual(self?.fileManager.fileExistsCallCount, 0)
                    XCTAssertEqual(self?.fileManager.removeItemCallCount, 0)
                    
                default:
                    XCTFail()
                }
                
                self?.scheduler.stop()
            }
            .disposed(by: disposeBag)
        
        self.scheduler.start()
    }
}
