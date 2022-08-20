import Foundation
import RxSwift
import RxRelay

protocol ColorPickerViewModelProtocol {
    var selectedColor: PublishSubject<String> { get }
}

final class ColorPickerViewModel: ColorPickerViewModelProtocol {
    let selectedColor = PublishSubject<String>()

    private var disposeBag = DisposeBag()

    init(colorStream: PublishSubject<String>) {
        bind(to: colorStream)
    }
}

private extension ColorPickerViewModel {
    func bind(to colorStream: PublishSubject<String>) {
        selectedColor
            .bind(to: colorStream)
            .disposed(by: disposeBag)
    }
}
