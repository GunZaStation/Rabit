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
        
        let tabBarController = UITabBarController()
        let first = ViewController()
        let firstTabBarItem = TabBarItems(first)
        first.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: firstTabBarItem.imageName),
            tag: firstTabBarItem.rawValue
        )
        first.tabBarItem.imageInsets = UIEdgeInsets(top: 22, left: 0, bottom: -22, right: 0)
        
        let second = ViewController()
        let secondTabBarItem = TabBarItems(second)
        second.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: secondTabBarItem.imageName),
            tag: secondTabBarItem.rawValue
        )
        second.tabBarItem.imageInsets = UIEdgeInsets(top: 22, left: 0, bottom: -22, right: 0)
        
        tabBarController.viewControllers = [first,second]
        navigationController.pushViewController(tabBarController, animated: false)
    }
}

extension MainCoordinator {
    
    enum TabBarItems: Int {
        case mainViewController = 0
        case albumViewController = 1
        case none = 2
        
        var imageName: String {
            switch self {
            case .mainViewController:
                return "mainTabIcon"
            case .albumViewController:
                return "albumTabIcon"
            case .none:
                return ""
            }
        }
        
        init(_ viewController: UIViewController) {
            let map = [
                ObjectIdentifier(ViewController.self):
                    TabBarItems.mainViewController,
            ]
            self = map[ObjectIdentifier(type(of:viewController))] ?? .none
        }
    }
    
}
