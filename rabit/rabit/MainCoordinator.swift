import UIKit

final class MainCoordinator: Coordinator {
    
    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {

        createChildrenCoordinators()

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = children.compactMap {
            $0.navigationController
        }

        navigationController.pushViewController(tabBarController, animated: false)
    }

    private func createChildrenCoordinators() {
        ChildType.allCases.forEach {
            let coordinator = $0.coordinator
            coordinator.parentCoordiantor = self
            coordinator.navigationController.tabBarItem = $0.tabBarItem
            children.append(coordinator)
            coordinator.start()
        }
    }
}

// MARK: - Child Coordinator 타입
private extension MainCoordinator {

    enum ChildType: Int, CaseIterable {

        case goalCoordinator = 0
        case albumCoordinator = 1

        var coordinator: Coordinator {
            switch self {
            case .goalCoordinator:
                return GoalCoordinator()
            case .albumCoordinator:
                return AlbumCoordinator()
            }
        }

        var tabBarItem: UITabBarItem {
            switch self {
            case .goalCoordinator:
                return UITabBarItem(title: nil, image: UIImage(systemName: "pencil"), tag: 0)
            case .albumCoordinator:
                return UITabBarItem(title: nil, image: UIImage(systemName: "pencil"), tag: 1)
            }
        }
    }
}
