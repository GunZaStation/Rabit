import UIKit
import RxSwift
import RxRelay

protocol GoalNavigation {
    
    var showCategoryAddView: PublishRelay<Void> { get }
    var closeCategoryAddView: PublishRelay<Void> { get }
    var showGoalAddView: PublishRelay<Void> { get }
    var closeGoalAddView: PublishRelay<Void> { get }
}

final class GoalCoordinator: Coordinator, GoalNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    let showCategoryAddView = PublishRelay<Void>()
    let closeCategoryAddView = PublishRelay<Void>()
    let showGoalAddView = PublishRelay<Void>()
    let closeGoalAddView = PublishRelay<Void>()
    
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
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: false)
            })
            .disposed(by: disposeBag)
        
        showGoalAddView
            .bind(onNext: presentGoalAddViewController)
            .disposed(by: disposeBag)
        
        closeGoalAddView
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: true)
            })
            .disposed(by: disposeBag)
    }

    func start() {
        parentCoordiantor?.navigationController.setNavigationBarHidden(true, animated: false)
        pushGoalListViewController()
        bind()
    }
    
    private func pushGoalListViewController() {
        let viewModel = GoalListViewModel(navigation: self)
        let viewController = GoalListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func presentCategoryAddViewController() {

        let viewModel = CategoryAddViewModel(navigation: self)
        let viewController = CategoryAddViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        navigationController.present(viewController, animated: false)
    }
    
    private func dismissCurrentView(animated: Bool) {
        
        navigationController.presentedViewController?.dismiss(animated: animated)
    }
    
    private func presentGoalAddViewController() {

        let viewModel = GoalAddViewModel(navigation: self)
        let viewController = GoalAddViewController(viewModel: viewModel)
        navigationController.present(viewController, animated: true)
    }
}
