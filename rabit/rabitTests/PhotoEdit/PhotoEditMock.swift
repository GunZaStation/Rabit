import Foundation
import RxRelay
import RxSwift
@testable import rabit

final class PhotoEditNavigationMock: PhotoEditNavigation {
    var didTapSelectColorButton: PublishRelay<BehaviorRelay<String>> = .init()
    
    var didTapSelectStyleButton: PublishRelay<BehaviorRelay<Album.Item>> = .init()
    
    var didTapBackButtonSetCount = BehaviorRelay<Int>(value: 0)
    var didTapBackButton: PublishRelay<Void> = .init()
    
    var didChangePhotoSetCount = BehaviorRelay<Int>(value: 0)
    var didChangePhoto: PublishRelay<Void> = .init()
    
    private var disposeBag: DisposeBag

    init() {
        self.disposeBag = DisposeBag()

        didTapBackButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapBackButtonSetCount.value
                return prevValue + 1
            }
            .bind(to: didTapBackButtonSetCount)
            .disposed(by: disposeBag)

        didChangePhoto
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didChangePhotoSetCount.value
                return prevValue + 1
            }
            .bind(to: didChangePhotoSetCount)
            .disposed(by: disposeBag)
    }
}
