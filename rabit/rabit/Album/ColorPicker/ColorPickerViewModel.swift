import Foundation
import RxSwift
import RxRelay
import UIKit

protocol ColorPickerViewModelProtocol {
    var selectedColor: PublishSubject<UIColor> { get }
}

final class ColorPickerViewModel: ColorPickerViewModelProtocol {
    let selectedColor = PublishSubject<UIColor>()

    private var disposeBag = DisposeBag()
}
