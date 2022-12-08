import RxSwift
import RxRelay
@testable import rabit

final class ColorSelectNavigationMock: ColorSelectNavigation {
    var didTapCloseColorSelectButton: PublishRelay<Void> = .init()
    
    var didTapCloseColorSelectButtonSetCount = BehaviorRelay<Int>(value: 0)
    
    private var disposeBag: DisposeBag
    
    init() {
        disposeBag = DisposeBag()
        
        didTapCloseColorSelectButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseColorSelectButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseColorSelectButtonSetCount)
            .disposed(by: disposeBag)
    }
}

