import Foundation
import RxSwift
import RxRelay

protocol ColorSelectViewModelInput {
    var selectedColor: BehaviorRelay<String> { get }
    var closeColorSelectRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol ColorSelectViewModelOutput {
    var presetColors: [String] { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
}

protocol ColorSelectViewModelProtocol: ColorSelectViewModelInput, ColorSelectViewModelOutput { }

final class ColorSelectViewModel: ColorSelectViewModelProtocol {
    let selectedColor: BehaviorRelay<String>
    let closeColorSelectRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let saveButtonState = BehaviorRelay<Bool>(value: false)
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
        colorStream: BehaviorRelay<String>,
        navigation: ColorSelectNavigation
    ) {
        selectedColor = .init(value: colorStream.value)
        bind(to: colorStream)
        bind(to: navigation)
    }
}

private extension ColorSelectViewModel {
    func bind(to colorStream: BehaviorRelay<String>) {
        saveButtonTouched.withLatestFrom(selectedColor)
            .bind(to: colorStream)
            .disposed(by: disposeBag)

        selectedColor
            .map {
                $0 != colorStream.value
            }
            .bind(to: saveButtonState)
            .disposed(by: disposeBag)
    }

    func bind(to navigation: ColorSelectNavigation) {
        closeColorSelectRequested
            .bind(to: navigation.didTapCloseColorSelectButton)
            .disposed(by: disposeBag)
    }
}
