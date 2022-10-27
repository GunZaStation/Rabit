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
        show(PhotoEditViewController.self, with: selectedPhoto)
    }

    func dismissPhotoEditView() {
        navigationController.presentedViewController?.dismiss(animated: true)
    }

    func presentColorSelectView(colorStream: BehaviorRelay<String>) {
        show(ColorSelectViewController.self, with: colorStream)
    }

    func dismissColorSelectView() {
        navigationController.presentedViewController?.dismiss(animated: false)
    }

    func presentStyleSelectView(photoStream: BehaviorRelay<Album.Item>) {
        show(StyleSelectViewController.self, with: photoStream)
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

    func show<T: ViewControllable>(_ viewController: T.Type, with data: Any) {
        let dic: [ObjectIdentifier: Any] = [
            ObjectIdentifier(PhotoEditViewController.self): PhotoEditViewModel(
                photoStream: (data as? BehaviorRelay<Photo>) ?? BehaviorRelay<Photo>(value: Photo()),
                repository: AlbumRepository(),
                navigation: self
            ),
            ObjectIdentifier(ColorSelectViewController.self): ColorSelectViewModel(
                colorStream: (data as? BehaviorRelay<String>) ?? BehaviorRelay<String>(value: ""),
                navigation: self
            ),
            ObjectIdentifier(StyleSelectViewController.self): StyleSelectViewModel(
                photoStream: (data as? BehaviorRelay<Photo>) ?? BehaviorRelay<Photo>(value: Photo()),
                navigation: self
            )
        ]

        guard let viewModel = dic[ObjectIdentifier(viewController)] as? T.ViewModel else {
            return
        }
        let viewController = viewController.init(viewModel: viewModel)

        if let presentedViewController = navigationController.presentedViewController {
            viewController.modalPresentationStyle = .overFullScreen
            presentedViewController.present(viewController, animated: true)
        } else {
            navigationController.present(viewController, animated: true)
        }
    }
}
