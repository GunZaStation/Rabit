import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: BottomSheet {
    
    var isClosed: ControlEvent<Void> {
        base.rx.controlEvent(.valueChanged)
    }
}
