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

        let tabBarController = createTabBarController()
        navigationController.pushViewController(tabBarController, animated: false)
    }

    private func createChildrenCoordinators() {
        ChildType.allCases.forEach {
            let coordinator = $0.coordinator
            coordinator.navigationController.tabBarItem = $0.tabBarItem
            coordinator.navigationController.tabBarItem.title = ""

            addChild(coordinator)
            coordinator.start()
        }
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = children.compactMap {
            $0.navigationController
        }
        tabBarController.tabBar.tintColor = UIColor(named: "second")

        tabBarController.tabBar.selectionIndicatorImage = UIImage.imageWithColor(
            color: UIColor(hexRGBA: "#EE5B0BB7"),
            size: CGSize(width: 35, height: 35)
        )

        return tabBarController
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
                return UITabBarItem(
                    title: nil,
                    image: UIImage(named: "goal_tabIcon"),
                    tag: 0
                )
            case .albumCoordinator:
                return UITabBarItem(
                    title: nil,
                    image: UIImage(named: "album_tabIcon"),
                    tag: 1
                )
            }
        }
    }
}
