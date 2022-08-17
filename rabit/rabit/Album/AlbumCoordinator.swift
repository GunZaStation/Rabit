import UIKit
import RxSwift
import RxRelay

final class AlbumCoordinator: Coordinator {
protocol PhotoEditNavigation {
    var showColorPickerView: PublishRelay<Void> { get }
    var showStylePickerView: PublishRelay<Void> { get }
    var closePhotoEditView: PublishRelay<Void> { get }
}

final class AlbumCoordinator: Coordinator, PhotoEditNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    let showColorPickerView = PublishRelay<Void>()
    let showStylePickerView = PublishRelay<Void>()
    let closePhotoEditView = PublishRelay<Void>()

    private var disposeBag = DisposeBag()
    init() {
        self.navigationController = UINavigationController()

        bind()
    }

    func start() {
        let repository = AlbumRepository()
        let viewModel = AlbumViewModel(repository: repository)
        let viewController = AlbumViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }
}

private extension AlbumCoordinator {
    func bind() {
        closePhotoEditView
            .bind(onNext: dismissPhotoEditView)
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
}
