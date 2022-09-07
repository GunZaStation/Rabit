import UIKit
import RxSwift
import RxRelay

protocol GoalNavigation {
    
    var showCategoryAddView: PublishRelay<Void> { get }
    var closeCategoryAddView: PublishRelay<Void> { get }
    var showGoalAddView: PublishRelay<Void> { get }
    var closeGoalAddView: PublishRelay<Void> { get }
    var showPeriodSelectView: PublishRelay<BehaviorRelay<Period>> { get }
    var closePeriodSelectView: PublishRelay<Void> { get }
    var showTimeSelectView: PublishRelay<BehaviorRelay<CertifiableTime>> { get }
    var closeTimeSelectView: PublishRelay<Void> { get }
}

final class GoalCoordinator: Coordinator, GoalNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    let showCategoryAddView = PublishRelay<Void>()
    let closeCategoryAddView = PublishRelay<Void>()
    let showGoalAddView = PublishRelay<Void>()
    let closeGoalAddView = PublishRelay<Void>()
    let showPeriodSelectView = PublishRelay<BehaviorRelay<Period>>()
    let closePeriodSelectView = PublishRelay<Void>()
    let showTimeSelectView = PublishRelay<BehaviorRelay<CertifiableTime>>()
    let closeTimeSelectView = PublishRelay<Void>()
    
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
        
        showPeriodSelectView
            .bind(onNext: presentPeriodSelectViewController)
            .disposed(by: disposeBag)
        
        closePeriodSelectView
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: false)
            })
            .disposed(by: disposeBag)
        
        showTimeSelectView
            .bind(onNext: presentTimeSelectViewController)
            .disposed(by: disposeBag)
        
        closeTimeSelectView
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: false)
            })
            .disposed(by: disposeBag)
    }

    func start() {
        parentCoordiantor?.navigationController.setNavigationBarHidden(true, animated: false)
        pushGoalListViewController()
        bind()
    }
}

private extension GoalCoordinator {
    
    func pushGoalListViewController() {
        let viewModel = GoalListViewModel(navigation: self)
        let viewController = GoalListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCategoryAddViewController() {

        let viewModel = CategoryAddViewModel(navigation: self)
        let viewController = CategoryAddViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.present(viewController, animated: false)
    }
    
    func dismissCurrentView(animated: Bool) {
        
        navigationController.presentedViewController?.dismiss(animated: animated)
    }
    
    func presentGoalAddViewController() {

        let viewModel = GoalAddViewModel(navigation: self)
        let viewController = GoalAddViewController(viewModel: viewModel)
        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    func presentPeriodSelectViewController(with periodStream: BehaviorRelay<Period>) {
        
        let viewModel = PeriodSelectViewModel(
            navigation: self,
            usecase: CalendarUsecase(),
            with: periodStream
        )
        let viewController = PeriodSelectViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.presentedViewController?.present(viewController, animated: false)
    }
    
    func presentTimeSelectViewController(with timeStream: BehaviorRelay<CertifiableTime>) {
        
        let viewModel = TimeSelectViewModel(navigation: self, with: timeStream)
        let viewController = TimeSelectViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.presentedViewController?.present(viewController, animated: false)
    }
}
