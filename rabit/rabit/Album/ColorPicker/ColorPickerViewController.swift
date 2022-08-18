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

        setupViews()
        bind()
    }
}

@available(iOS 14.0, *)
private extension ColorPickerViewController {
    func setupViews() {
        view.backgroundColor = UIColor(named: "first")

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: nil, action: nil
        )
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.doneButtonTouched)
            .disposed(by: disposeBag)
    }
}

@available(iOS 14.0, *)
extension ColorPickerViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        // UIColorPickerViewController는 rxSwift에 구현되어있지않아, 부득이하게 이런 방식으로 바인딩처리..
        viewModel?.selectedColor.onNext(color)
    }
}
