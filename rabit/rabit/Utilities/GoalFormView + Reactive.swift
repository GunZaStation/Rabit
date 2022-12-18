import UIKit
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
    
    var subtitle: ControlProperty<String> {
        base.rx.controlProperty(
            editingEvents: .valueChanged,
            getter: { $0.subtitle },
            setter: { formView, description in
                formView.subtitle = description
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
    
    var delegate: DelegateProxy<GoalFormView, GoalFormViewDelegate> {
        return RxGoalFormViewDelegateProxy.proxy(for: base)
    }
    
    var periodFieldTouched: Observable<Void> {
        delegate.methodInvoked(#selector(GoalFormViewDelegate.periodFiledTouched))
            .map { _ in Void() }
    }
    
    var timeFieldTouched: Observable<Void> {
        delegate.methodInvoked(#selector(GoalFormViewDelegate.timeFieldTouched))
            .map { _ in Void() }
    }
}

class RxGoalFormViewDelegateProxy: DelegateProxy<GoalFormView, GoalFormViewDelegate>, DelegateProxyType, GoalFormViewDelegate {
    
    static func registerKnownImplementations() {
        self.register { RxGoalFormViewDelegateProxy(parentObject: $0, delegateProxy: self) }
    }
   
    static func currentDelegate(for object: ParentObject) -> Delegate? {
        object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: Delegate?, to object: ParentObject) {
        object.delegate = delegate
    }
}
