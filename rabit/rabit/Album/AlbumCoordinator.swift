import UIKit
import RxSwift
import RxRelay

protocol AlbumNavigation {
    var showPhotoEditView: PublishRelay<BehaviorRelay<Album.Item>> { get }
    var closeColorSelectView: PublishRelay<Void> { get }
    var didChangePhoto: PublishRelay<Void> { get }
}

protocol PhotoEditNavigation {
    var showColorSelectView: PublishRelay<BehaviorRelay<String>> { get }
    var showStylePickerView: PublishRelay<Void> { get }
    var closePhotoEditView: PublishRelay<Void> { get }
    var didChangePhoto: PublishRelay<Void> { get }
}

protocol ColorSelectNavigation {
    var closeColorSelectView: PublishRelay<Void> { get }
    var saveSelectedColor: PublishRelay<Void> { get }
}

final class AlbumCoordinator: Coordinator, PhotoEditNavigation, AlbumNavigation, ColorSelectNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    let showPhotoEditView = PublishRelay<BehaviorRelay<Album.Item>>()
    let showColorSelectView = PublishRelay<BehaviorRelay<String>>()
    let showStylePickerView = PublishRelay<Void>()
    let closePhotoEditView = PublishRelay<Void>()
    let didChangePhoto = PublishRelay<Void>()
    let closeColorSelectView = PublishRelay<Void>()
    let saveSelectedColor = PublishRelay<Void>()

    private var disposeBag = DisposeBag()
    init() {
        self.navigationController = UINavigationController()

        bind()
    }

    func start() {
        let repository = AlbumRepository()
        let viewModel = AlbumViewModel(
            repository: repository,
            navigation: self
        )
        let viewController = AlbumViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}

// MARK: - Navigation methods
private extension AlbumCoordinator {
    func presentPhotoEditView(_ selectedPhoto: BehaviorRelay<Album.Item>) {
        let repository = AlbumRepository()
        let viewModel = PhotoEditViewModel(
            photoStream: selectedPhoto,
            repository: repository,
            navigation: self
        )
        let viewController = PhotoEdtiViewController(viewModel: viewModel)

        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }

    func dismissPhotoEditView() {
        navigationController.presentedViewController?.dismiss(animated: true)
    }

    func presentColorSelectView(colorStream: BehaviorRelay<String>) {
        let viewModel = ColorSelectViewModel(
            colorStream: colorStream,
            navigation: self
        )

        let viewController = ColorSelectViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationController.presentedViewController?.present(viewController, animated: false)
    }

    func dismissColorSelectView() {
        navigationController.presentedViewController?.dismiss(animated: false)
    }

    func pushStylePickerView() {
        guard let navigationController = self.navigationController.presentedViewController as? UINavigationController else { return }

        // TODO: StylePickerView 완성 후 추가
//        navigationController.pushViewController(stylePickerViewController(), animated: true)
    }
}

// MARK: - Private methods
private extension AlbumCoordinator {
    func bind() {
        showPhotoEditView
            .bind(onNext: presentPhotoEditView(_:))
            .disposed(by: disposeBag)

        closePhotoEditView
            .bind(onNext: dismissPhotoEditView)
            .disposed(by: disposeBag)

        didChangePhoto
            .bind(onNext: dismissPhotoEditView)
            .disposed(by: disposeBag)

        showColorSelectView
            .bind(onNext: presentColorSelectView(colorStream:))
            .disposed(by: disposeBag)

        showStylePickerView
            .bind(onNext: pushStylePickerView)
            .disposed(by: disposeBag)

        closeColorSelectView
            .bind(onNext: dismissColorSelectView)
            .disposed(by: disposeBag)

        saveSelectedColor
            .bind(onNext: dismissColorSelectView)
            .disposed(by: disposeBag)
    }
}
