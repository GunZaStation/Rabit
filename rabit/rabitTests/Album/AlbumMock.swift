import RxSwift
import RxRelay
@testable import rabit

final class AlbumNavigationMock: AlbumNavigation {
    var didSelectPhoto: PublishRelay<BehaviorRelay<Album.Item>> = .init()
    var didChangePhoto: PublishRelay<Void> = .init()
    
    var didSelectPhotoValue: BehaviorRelay<Album.Item>?
    
    private var disposeBag: DisposeBag
    init() {
        disposeBag = DisposeBag()
        
        didSelectPhoto
            .withUnretained(self)
            .bind { navigation, value in
                navigation.didSelectPhotoValue = value
            }
            .disposed(by: disposeBag)
    }
}
