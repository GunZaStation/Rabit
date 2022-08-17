import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhotoEdtiViewController: UIViewController {
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let colorPickerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("글씨 색깔 변경", for: .normal)
        button.setImage(UIImage(systemName: "paintpalette"), for: .normal)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(named: "second")
        button.roundCorners()
        return button
    }()

    private let stylePickerButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("글씨 스타일 변경", for: .normal)
        button.setImage(UIImage(systemName: "scribble"), for: .normal)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(named: "second")
        button.roundCorners()
        return button
    }()

    private var viewModel: PhotoEditViewModelProtocol?

    private var disposeBag = DisposeBag()

    convenience init(viewModel: PhotoEditViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        navigationController?.navigationBar.isHidden = true
    }
}

private extension PhotoEdtiViewController {
    func setupViews() {
        view.backgroundColor = UIColor(named: "first")
        view.addSubview(photoImageView)
        view.addSubview(colorPickerButton)
        view.addSubview(stylePickerButton)

        setNavigationBarButton()

        photoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }

        colorPickerButton.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(100)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }

        stylePickerButton.snp.makeConstraints { make in
            make.top.equalTo(colorPickerButton.snp.bottom).offset(30)
            make.leading.trailing.height.equalTo(colorPickerButton)
        }
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.imageData
            .compactMap {
                UIImage(data: $0)
            }
            .bind(to: photoImageView.rx.image)
            .disposed(by: disposeBag)

        colorPickerButton.rx.tap
            .bind(to: viewModel.colorPickerButtonTouched)
            .disposed(by: disposeBag)

        stylePickerButton.rx.tap
            .bind(to: viewModel.stylePickerButtonTouched)
            .disposed(by: disposeBag)

        navigationItem.leftBarButtonItem?.rx.tap
            .bind(to: viewModel.backButtonTouched)
            .disposed(by: disposeBag)
    }

    func setNavigationBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(
                systemName: "chevron.backward",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 18,
                    weight: .semibold)
                ),
            style: .plain,
            target: nil, action: nil
        )
    }
}
