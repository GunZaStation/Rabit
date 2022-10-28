import UIKit
import RxSwift
import RxRelay

enum PhotoEditMode {
    case editProperty
    case addNewPhoto
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

final class PhotoEditCoordinator: Coordinator, PhotoEditNavigation, ColorSelectNavigation, StyleSelectNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    private let photoStream: BehaviorRelay<Album.Item>

    let showColorSelectView = PublishRelay<BehaviorRelay<String>>()
    let showStyleSelectView = PublishRelay<BehaviorRelay<Album.Item>>()
    let closePhotoEditView = PublishRelay<Void>()
    let didChangePhoto = PublishRelay<Void>()

    let closeColorSelectView = PublishRelay<Void>()

    let closeStyleSelectView = PublishRelay<Void>()

    private let photoEditMode: PhotoEditMode

    private var disposeBag = DisposeBag()

    init(
        navigationController: UINavigationController,
        photoStream: BehaviorRelay<Album.Item>,
        photoEditMode: PhotoEditMode = .editProperty
    ) {
        self.navigationController = navigationController
        self.photoEditMode = photoEditMode
        self.photoStream = .init(value: photoStream.value)
        bind(to: photoStream)
        bind()
    }

    func start() {
        let repository = AlbumRepository()
        let viewModel = PhotoEditViewModel(
            photoStream: photoStream,
            repository: repository,
            photoEditMode: photoEditMode,
            navigation: self
        )
        let viewController = PhotoEditViewController(viewModel: viewModel)

        switch photoEditMode {
        case .editProperty:
            navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
        case .addNewPhoto:
            navigationController.pushViewController(viewController, animated: true)
        }
        
    }
}

private extension PhotoEditCoordinator {
    func bind() {
        showColorSelectView
            .withUnretained(self)
            .bind { coordinator, colorStream in
                coordinator.presentColorSelectView(colorStream: colorStream)
            }
            .disposed(by: disposeBag)

        showStyleSelectView
            .withUnretained(self)
            .bind { coordinator, photoStream in
                coordinator.presentStyleSelectView(photoStream: photoStream)
            }
            .disposed(by: disposeBag)

        closePhotoEditView
            .withUnretained(self)
            .bind { coordinator, _ in
                coordinator.detachPhotoEditCoordinator()
            }
            .disposed(by: disposeBag)

        didChangePhoto
            .withUnretained(self)
            .bind { coordinator, _ in
                coordinator.detachPhotoEditCoordinator()
            }
            .disposed(by: disposeBag)
        
        closeColorSelectView
            .withUnretained(self)
            .bind { coordinator, _ in
                coordinator.dismissCurrentView()
            }
            .disposed(by: disposeBag)

        closeStyleSelectView
            .withUnretained(self)
            .bind { coordinator, _ in
                coordinator.dismissCurrentView()
            }
            .disposed(by: disposeBag)
    }

    func bind(to photoStream: BehaviorRelay<Album.Item>) {
        self.photoStream
            .bind(to: photoStream)
            .disposed(by: disposeBag)
    }
}

// MARK: - Navigation methods
private extension PhotoEditCoordinator {
    func presentColorSelectView(colorStream: BehaviorRelay<String>) {
        let viewModel = ColorSelectViewModel(
            colorStream: colorStream,
            navigation: self
        )
        let viewController = ColorSelectViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen

        if let presentedViewController = navigationController.presentedViewController {
            presentedViewController.present(viewController, animated: false)
            return
        }

        navigationController.present(viewController, animated: false)
    }

    func presentStyleSelectView(photoStream: BehaviorRelay<Album.Item>) {
        let viewModel = StyleSelectViewModel(
            photoStream: photoStream,
            navigation: self
        )

        let viewController = StyleSelectViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen

        if let presentedViewController = navigationController.presentedViewController {
            presentedViewController.present(viewController, animated: false)
            return
        }

        navigationController.present(viewController, animated: false)
    }

    func dismissCurrentView() {
        navigationController.presentedViewController?.dismiss(animated: false)
    }

    func detachPhotoEditCoordinator() {
        if let presentedViewController = navigationController.presentedViewController {
            presentedViewController.dismiss(animated: true)
        } else {
            let destinationViewController = navigationController.viewControllers
                .filter { type(of: $0) == GoalDetailViewController.self }[0]
            navigationController.popToViewController(destinationViewController, animated: true)
        }

        parentCoordiantor?.childDidFinish(self)
    }
}
