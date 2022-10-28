import UIKit
import RxSwift
import RxRelay

protocol AlbumNavigation {
    var showPhotoEditView: PublishRelay<BehaviorRelay<Album.Item>> { get }
    var didChangePhoto: PublishRelay<Void> { get }
}

final class AlbumCoordinator: Coordinator, AlbumNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    let showPhotoEditView = PublishRelay<BehaviorRelay<Album.Item>>()
    let didChangePhoto = PublishRelay<Void>()

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
    func attachPhotoEditCoordinator(_ photoStream: BehaviorRelay<Album.Item>) {
        let photoEditCoordinator = PhotoEditCoordinator(
            navigationController: navigationController,
            photoStream: photoStream
        )
        photoEditCoordinator.parentCoordiantor = self
        photoEditCoordinator.didChangePhoto
            .bind(to: didChangePhoto)
            .disposed(by: disposeBag)

        children.append(photoEditCoordinator)

        photoEditCoordinator.start()
    }
}

// MARK: - Private methods
private extension AlbumCoordinator {
    func bind() {
        showPhotoEditView
            .bind(onNext: attachPhotoEditCoordinator(_:))
            .disposed(by: disposeBag)
    }
}
