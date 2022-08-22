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
        tabBarController.tabBar.tintColor = UIColor(named: "second")
        tabBarController.tabBar.selectionIndicatorImage = UIImage.imageWithColor(
            color: UIColor(named: "fourth"),
            size: CGSize(width: 60, height: 60)
        )
        navigationController.pushViewController(tabBarController, animated: false)
    }

    private func createChildrenCoordinators() {
        ChildType.allCases.forEach {
            let coordinator = $0.coordinator
            coordinator.parentCoordiantor = self
            coordinator.navigationController.tabBarItem = $0.tabBarItem
            coordinator.navigationController.tabBarItem.imageInsets = UIEdgeInsets(
                top: 22,
                left: 0,
                bottom: -22,
                right: 0
            )

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
                return UITabBarItem(
                    title: nil,
                    image: UIImage(named: "goal_tabIcon")?.resized(to: CGSize(width: 45, height: 45)),
                    tag: 0
                )
            case .albumCoordinator:
                return UITabBarItem(
                    title: nil,
                    image: UIImage(named: "album_tabIcon")?.resized(to: CGSize(width: 45, height: 45)),
                    tag: 1
                )
            }
        }
    }
}
