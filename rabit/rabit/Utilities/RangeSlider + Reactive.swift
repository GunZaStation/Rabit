import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: RangeSlider {
    
    var leftValue: ControlProperty<Double> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.leftValue },
            setter: { _, _ in }
        )
    }
    
    var rightValue: ControlProperty<Double> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.rightValue },
            setter: { _, _ in }
        )
    }
}

