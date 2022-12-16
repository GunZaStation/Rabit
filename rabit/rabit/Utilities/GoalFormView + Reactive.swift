import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base == GoalFormView {
    
    var title: ControlProperty<String> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.title },
            setter: { formView, title in
                formView.title = title
            }
        )
    }
    
    var goalDescription: ControlProperty<String> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.goalDescription },
            setter: { formView, description in
                formView.goalDescription = description
            }
        )
    }
    
    var period: ControlProperty<String> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.period },
            setter: { formView, period in
                formView.period = period
            }
        )
    }
    
    var time: ControlProperty<String> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.time },
            setter: { formView, time in
                formView.time = time
            }
        )
    }
}
