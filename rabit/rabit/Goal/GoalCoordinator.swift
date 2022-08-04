import UIKit

final class GoalCoordinator: Coordinator {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController

    init() {
        self.navigationController = UINavigationController()
        self.navigationController.view.backgroundColor = .systemBackground
    }

    func start() {
        parentCoordiantor?.navigationController.setNavigationBarHidden(true, animated: false)
        pushGoalListViewController()
    }
    
    private func pushGoalListViewController() {
        let viewModel = GoalListViewModel()
        let viewController = GoalListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
