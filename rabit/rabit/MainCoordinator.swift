import UIKit

final class MainCoordinator: Coordinator {
    
    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    //TabBarController 생성 후 보여주기
    func start() {
        
        let tabbarController = UITabBarController()
        tabbarController.viewControllers = [ViewController()]
    }
}
