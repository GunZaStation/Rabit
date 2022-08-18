import UIKit
import RxSwift
import RxRelay

protocol AlbumNavigation {
    var showPhotoEditView: PublishRelay<Album.Item> { get }
}

protocol PhotoEditNavigation {
    var showColorPickerView: PublishRelay<Void> { get }
    var showStylePickerView: PublishRelay<Void> { get }
    var closePhotoEditView: PublishRelay<Void> { get }
}

protocol ColorPickerNavigation {
    var closeColorPickerView: PublishRelay<Void> { get }
}

final class AlbumCoordinator: Coordinator, PhotoEditNavigation, AlbumNavigation, ColorPickerNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    let showPhotoEditView = PublishRelay<Album.Item>()
    let showColorPickerView = PublishRelay<Void>()
    let showStylePickerView = PublishRelay<Void>()
    let closePhotoEditView = PublishRelay<Void>()
    let closeColorPickerView = PublishRelay<Void>()

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

private extension AlbumCoordinator {
    func bind() {
        showPhotoEditView
            .bind(onNext: presentPhotoEditView(_:))
            .disposed(by: disposeBag)

        closePhotoEditView
            .bind(onNext: dismissPhotoEditView)
            .disposed(by: disposeBag)

        showColorPickerView
            .bind(onNext: pushColorPickerView)
            .disposed(by: disposeBag)

        showStylePickerView
            .bind(onNext: pushStylePickerView)
            .disposed(by: disposeBag)

        closeColorPickerView
            .bind(onNext: dismissColorPickerView)
            .disposed(by: disposeBag)
    }

    func presentPhotoEditView(_ selectedImageData: Data) {
        let viewModel = PhotoEditViewModel(
            selectedData: selectedImageData,
            navigation: self
        )
        let viewController = PhotoEdtiViewController(viewModel: viewModel)

        let navigationController = UINavigationController(rootViewController: viewController)

        self.navigationController.present(navigationController, animated: true)
    }

    func dismissPhotoEditView() {
        navigationController.presentedViewController?.dismiss(animated: true)
    }

    func pushColorPickerView() {
        guard let navigationController = self.navigationController.presentedViewController as? UINavigationController else { return }

        if #available(iOS 14.0, *) {
            let viewModel = ColorPickerViewModel(navigation: self)
            let viewController = ColorPickerViewController(viewModel: viewModel)
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func pushStylePickerView() {
        guard let navigationController = self.navigationController.presentedViewController as? UINavigationController else { return }

        // TODO: StylePickerView 완성 후 추가
//        navigationController.pushViewController(stylePickerViewController(), animated: true)
    }

    func dismissColorPickerView() {
        guard let navigationController = self.navigationController.presentedViewController as? UINavigationController else { return }

        navigationController.popViewController(animated: true)
    }
}
