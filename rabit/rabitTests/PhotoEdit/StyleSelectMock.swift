import Foundation
import RxSwift
import RxRelay
@testable import rabit

final class StyleSelectNavigationMock: StyleSelectNavigation {
    var didTapCloseStyleSelectButton: PublishRelay<Void> = .init()
    
    var didTapCloseStyleSelectButtonSetCount = BehaviorRelay<Int>(value: 0)
    
    private var disposeBag: DisposeBag
    
    init() {
        self.disposeBag = DisposeBag()
        
        didTapCloseStyleSelectButton
            .withUnretained(self)
            .map { navigation, _ in
                let prevValue = navigation.didTapCloseStyleSelectButtonSetCount.value
                
                return prevValue + 1
            }
            .bind(to: didTapCloseStyleSelectButtonSetCount)
            .disposed(by: disposeBag)
    }
}
