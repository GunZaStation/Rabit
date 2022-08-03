import UIKit

final class AlbumCoordinator: Coordinator {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    init() {
        self.navigationController = UINavigationController()
    }

    func start() {
        let viewController = AlbumViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
}
