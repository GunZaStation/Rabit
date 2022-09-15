import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: RangeSlider {
    
    var leftValue: ControlProperty<Double> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.leftValue },
            setter: { rangeSlider, leftValue in
                rangeSlider.leftValue = leftValue
            }
        )
    }
    
    var rightValue: ControlProperty<Double> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.rightValue },
            setter: { rangeSlider, rightValue in
                rangeSlider.rightValue = rightValue
            }
        )
    }
}

