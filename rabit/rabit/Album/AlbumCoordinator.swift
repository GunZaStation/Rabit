import UIKit
import RxSwift
import RxRelay

protocol AlbumNavigation {
    var showPhotoEditView: PublishRelay<Album.Item> { get }
    var closeColorPickerView: PublishRelay<Void> { get }
    var closePhotoEditView: PublishRelay<Void> { get }
}

protocol PhotoEditNavigation {
    var showColorPickerView: PublishRelay<BehaviorRelay<String>> { get }
    var showStylePickerView: PublishRelay<Void> { get }
    var closePhotoEditView: PublishRelay<Void> { get }
}

protocol ColorPickerNavigation {
    var closeColorPickerView: PublishRelay<Void> { get }
    var saveSelectedColor: PublishRelay<Void> { get }
}

final class AlbumCoordinator: Coordinator, PhotoEditNavigation, AlbumNavigation, ColorPickerNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    let showPhotoEditView = PublishRelay<Album.Item>()
    let showColorPickerView = PublishRelay<BehaviorRelay<String>>()
    let showStylePickerView = PublishRelay<Void>()
    let closePhotoEditView = PublishRelay<Void>()
    let closeColorPickerView = PublishRelay<Void>()
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
    func presentPhotoEditView(_ selectedPhoto: Album.Item) {
        let repository = AlbumRepository()
        let viewModel = PhotoEditViewModel(
            selectedData: selectedPhoto,
            repository: repository,
            navigation: self
        )
        let viewController = PhotoEdtiViewController(viewModel: viewModel)

        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }

    func dismissPhotoEditView() {
        navigationController.presentedViewController?.dismiss(animated: true)
    }

    func presentColorPickerView(colorStream: BehaviorRelay<String>) {
        let viewModel = ColorPickerViewModel(
            colorStream: colorStream,
            navigation: self
        )

        let viewController = ColorPickerViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationController.presentedViewController?.present(viewController, animated: false)
    }

    func dismissColorPickerView() {
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

        showColorPickerView
            .bind(onNext: presentColorPickerView(colorStream:))
            .disposed(by: disposeBag)

        showStylePickerView
            .bind(onNext: pushStylePickerView)
            .disposed(by: disposeBag)

        closeColorPickerView
            .bind(onNext: dismissColorPickerView)
            .disposed(by: disposeBag)

        saveSelectedColor
            .bind(onNext: dismissColorPickerView)
            .disposed(by: disposeBag)
    }
}
