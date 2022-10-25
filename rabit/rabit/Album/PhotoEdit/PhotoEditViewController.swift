import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class PhotoEditViewController: UIViewController {
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private let selectColorButton: UIButton = {
        let button = UIButton()
        button.setTitle("글씨 색깔 변경", for: .normal)
        button.setImage(UIImage(systemName: "paintpalette"), for: .normal)
        button.tintColor = UIColor.white
        button.roundCorners()
        button.setBackgroundColor(UIColor(named: "second"), for: .normal)
        return button
    }()

    private let selectStyleButton: UIButton = {
        let button = UIButton()
        button.setTitle("글씨 스타일 변경", for: .normal)
        button.setImage(UIImage(systemName: "scribble"), for: .normal)
        button.tintColor = UIColor.white
        button.roundCorners()
        button.setBackgroundColor(UIColor(named: "second"), for: .normal)
        return button
    }()

    private let cancelButton: UIBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .close,
        target: nil,
        action: nil
    )

    private let saveButton: UIBarButtonItem = UIBarButtonItem(
        title: "저장",
        style: .done,
        target: nil,
        action: nil
    )

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
}

private extension PhotoEditViewController {
    func setupViews() {
        setAttributes()
        view.addSubview(photoImageView)
        view.addSubview(selectColorButton)
        view.addSubview(selectStyleButton)


        photoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(0)
            make.width.equalToSuperview()
        }

        selectColorButton.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(100)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().inset(15)
            make.height.equalTo(50)
        }

        selectStyleButton.snp.makeConstraints { make in
            make.top.equalTo(selectColorButton.snp.bottom).offset(30)
            make.leading.trailing.height.equalTo(selectColorButton)
        }
    }

    func setAttributes() {
        view.backgroundColor = UIColor(named: "first")
        setNavigationBarButton()
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        let imageLength = view.bounds.width
        let imageSize = CGSize(
            width: imageLength,
            height: imageLength
        )

        let updatedPhotoImage = viewModel.selectedPhotoData
            .map(\.imageData)
            .compactMap {
                $0.toDownsampledCGImage(
                    pointSize: imageSize,
                    scale: UIScreen.main.scale
                )
            }
            .compactMap(UIImage.init)
            .withLatestFrom(viewModel.selectedPhotoData) {
                $0.overlayText(of: $1)
            }
            .compactMap { $0 }
            .share(replay: 1)

        updatedPhotoImage
            .bind(to: photoImageView.rx.image)
            .disposed(by: disposeBag)

        updatedPhotoImage
            .withUnretained(self)
            .bind { viewController, image in
                viewController.resizePhotoImageView(with: image)
            }
            .disposed(by: disposeBag)

        selectColorButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.selectColorButtonTouched)
            .disposed(by: disposeBag)

        selectStyleButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.selectStyleButtonTouched)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.backButtonTouched)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)

        viewModel.saveButtonState
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    func setNavigationBarButton() {
        navigationItem.leftBarButtonItem = cancelButton

        navigationItem.rightBarButtonItem = saveButton
        saveButton.tintColor = UIColor(named: "second")
    }

    func resizePhotoImageView(with image: UIImage) {
        let referenceImageView = UIImageView(image: image)
        let ratio = referenceImageView.frame.height / referenceImageView.frame.width
        let currentWidth = view.frame.width

        photoImageView.snp.makeConstraints { make in
            make.height.equalTo(ratio * currentWidth)
        }
    }
}
