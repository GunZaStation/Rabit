import Foundation
import RxSwift
import RxRelay

protocol ColorPickerViewModelInput {
    var selectedColor: PublishSubject<String> { get }
    var backButtonTouched: PublishSubject<Void> { get }
}

protocol ColorPickerViewModelOutput {
    var presetColors: [String] { get }
}

protocol ColorPickerViewModelProtocol: ColorPickerViewModelInput, ColorPickerViewModelOutput { }

final class ColorPickerViewModel: ColorPickerViewModelProtocol {
    let selectedColor = PublishSubject<String>()
    let backButtonTouched = PublishSubject<Void>()
    let presetColors = [
        "#E4B6BC", "#E09681", "#000000",
        "#FFFFFF", "#003865", "#3BCF4E",
        "#9D693C", "#CE4438", "#94D3D3",
        "#BE73CE", "#424242", "#ECEDED",
        "#BCDF5D", "#EB7331", "#69C4D8",
        "#56AC97", "#FDEFEE", "#EF5C0C"
    ]

    private var disposeBag = DisposeBag()

    init(
        colorStream: PublishSubject<String>,
        navigation: ColorPickerNavigation
    ) {
        bind(to: colorStream)
        bind(to: navigation)
    }
}

private extension ColorPickerViewModel {
    func bind(to colorStream: PublishSubject<String>) {
        selectedColor
            .bind(to: colorStream)
            .disposed(by: disposeBag)
    }

    func bind(to navigation: ColorPickerNavigation) {
        backButtonTouched
            .bind(to: navigation.closeColorPickerView)
            .disposed(by: disposeBag)
    }
}
