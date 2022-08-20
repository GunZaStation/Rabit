import UIKit
import SnapKit
import RxSwift
import RxCocoa

@available(iOS 14.0, *)
final class ColorPickerViewController: UIColorPickerViewController {
    private var viewModel: ColorPickerViewModelProtocol?

    private var disposeBag = DisposeBag()

    convenience init(viewModel: ColorPickerViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
        self.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "first")
    }
}

@available(iOS 14.0, *)
extension ColorPickerViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        // UIColorPickerViewController는 rxSwift에 구현되어있지않아, 부득이하게 이런 방식으로 바인딩처리..
        viewModel?.selectedColor.onNext(color.toHexString())
    }
}
