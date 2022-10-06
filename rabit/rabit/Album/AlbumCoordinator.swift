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
    var showStyleSelectView: PublishRelay<BehaviorRelay<Album.Item>> { get }
    var closePhotoEditView: PublishRelay<Void> { get }
    var didChangePhoto: PublishRelay<Void> { get }
}

protocol ColorSelectNavigation {
    var closeColorSelectView: PublishRelay<Void> { get }
    var saveSelectedColor: PublishRelay<Void> { get }
}

protocol StyleSelectNavigation {
    var closeStyleSelectView: PublishRelay<Void> { get }
}

final class AlbumCoordinator: Coordinator, PhotoEditNavigation, AlbumNavigation, ColorSelectNavigation, StyleSelectNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    let showPhotoEditView = PublishRelay<BehaviorRelay<Album.Item>>()
    let showColorSelectView = PublishRelay<BehaviorRelay<String>>()
    let showStyleSelectView = PublishRelay<BehaviorRelay<Album.Item>>()
    let closePhotoEditView = PublishRelay<Void>()
    let didChangePhoto = PublishRelay<Void>()
    let closeColorSelectView = PublishRelay<Void>()
    let saveSelectedColor = PublishRelay<Void>()
    let closeStyleSelectView = PublishRelay<Void>()

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

    func presentStyleSelectView(photoStream: BehaviorRelay<Album.Item>) {
        let viewModel = StyleSelectViewModel(
            photoStream: photoStream,
            navigation: self
        )

        let viewController = StyleSelectViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.presentedViewController?.present(viewController, animated: true)
    }

    func dismissStyleSelectView() {
        navigationController.presentedViewController?.dismiss(animated: false)
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

        showStyleSelectView
            .bind(onNext: presentStyleSelectView(photoStream:))
            .disposed(by: disposeBag)

        closeColorSelectView
            .bind(onNext: dismissColorSelectView)
            .disposed(by: disposeBag)

        closeStyleSelectView
            .bind(onNext: dismissStyleSelectView)
            .disposed(by: disposeBag)
    }
}
