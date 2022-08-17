import UIKit
import RxSwift
import RxRelay

final class GoalCoordinator: Coordinator {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    let showCategoryAddView = PublishRelay<Void>()
    let closeCategoryAddView = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()

    init() {
        self.navigationController = UINavigationController()
        self.navigationController.view.backgroundColor = .systemBackground
    }
    
    private func bind() {
        
        showCategoryAddView
            .bind(onNext: presentCategoryAddViewController)
            .disposed(by: disposeBag)
        
        closeCategoryAddView
            .bind(onNext: dismissCategoryAddViewController)
            .disposed(by: disposeBag)
    }

    func start() {
        parentCoordiantor?.navigationController.setNavigationBarHidden(true, animated: false)
        pushGoalListViewController()
        bind()
    }
    
    private func pushGoalListViewController() {
        let viewModel = GoalListViewModel(coordinator: self)
        let viewController = GoalListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func presentCategoryAddViewController() {

        let viewModel = CategoryAddViewModel(coordinator: self)
        let viewController = CategoryAddViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationController.present(viewController, animated: false)
    }
    
    private func dismissCategoryAddViewController() {
        
        navigationController.presentedViewController?.dismiss(animated: false)
    }
}
