import Foundation
import RxSwift
import RxRelay
import UIKit

protocol ColorPickerViewModelInput {
    var doneButtonTouched: PublishRelay<Void> { get }
}

protocol ColorPickerViewModelOutput {
    var selectedColor: PublishSubject<UIColor> { get }
}

protocol ColorPickerViewModelProtocol: ColorPickerViewModelInput, ColorPickerViewModelOutput { }

final class ColorPickerViewModel: ColorPickerViewModelProtocol {
    let doneButtonTouched = PublishRelay<Void>()
    let selectedColor = PublishSubject<UIColor>()

    private var disposeBag = DisposeBag()

    init(navigation: ColorPickerNavigation) {
        bind(to: navigation)
    }
}

private extension ColorPickerViewModel {
    func bind(to navigation: ColorPickerNavigation) {
        doneButtonTouched
            .bind(to: navigation.closeColorPickerView)
            .disposed(by: disposeBag)
    }
}
