import UIKit

final class AppCoordinator: Coordinator {
    
    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator.parentCoordiantor = self
        children.append(mainCoordinator)
        mainCoordinator.start()
    }
}
