import UIKit

final class GoalCoordinator: Coordinator {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
    }

    func start() {
        let viewController = ViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}
