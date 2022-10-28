import UIKit
import RxSwift
import RxRelay

protocol GoalNavigation {
    
    var showCategoryAddView: PublishRelay<Void> { get }
    var closeCategoryAddView: PublishRelay<Void> { get }
    var showGoalAddView: PublishRelay<Category> { get }
    var closeGoalAddView: PublishRelay<Void> { get }
    var showPeriodSelectView: PublishRelay<BehaviorRelay<Period>> { get }
    var closePeriodSelectView: PublishRelay<Void> { get }
    var showTimeSelectView: PublishRelay<BehaviorRelay<CertifiableTime>> { get }
    var closeTimeSelectView: PublishRelay<Void> { get }
    var showGoalDetailView: PublishRelay<Goal> { get }
    var closeGoalDetailView: PublishRelay<Void> { get }
    var showCertPhotoCameraView: PublishRelay<Goal> { get }
    var showPhotoEditView: PublishRelay<BehaviorRelay<Photo>> { get }
}

final class GoalCoordinator: Coordinator, GoalNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    let showCategoryAddView = PublishRelay<Void>()
    let closeCategoryAddView = PublishRelay<Void>()
    let showGoalAddView = PublishRelay<Category>()
    let closeGoalAddView = PublishRelay<Void>()
    let showPeriodSelectView = PublishRelay<BehaviorRelay<Period>>()
    let closePeriodSelectView = PublishRelay<Void>()
    let showTimeSelectView = PublishRelay<BehaviorRelay<CertifiableTime>>()
    let closeTimeSelectView = PublishRelay<Void>()
    let showGoalDetailView = PublishRelay<Goal>()
    let closeGoalDetailView = PublishRelay<Void>()
    let showCertPhotoCameraView = PublishRelay<Goal>()
    let showPhotoEditView = PublishRelay<BehaviorRelay<Photo>>()

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
        
        showGoalDetailView
            .bind(onNext: pushGoalDetailViewController)
            .disposed(by: disposeBag)
        
        closeGoalDetailView
            .bind(onNext: popGoalDetailViewController)
            .disposed(by: disposeBag)
        
        showCertPhotoCameraView
            .bind(onNext: pushCertPhotoCameraView)
            .disposed(by: disposeBag)
        
        showPhotoEditView
            .bind(onNext: attachPhotoEditCoordinator(_:))
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
    
    func presentGoalAddViewController(category: Category) {

        let viewModel = GoalAddViewModel(navigation: self, category: category)
        let viewController = GoalAddViewController(viewModel: viewModel)
        navigationController.present(UINavigationController(rootViewController: viewController), animated: true)
    }
    
    func presentPeriodSelectViewController(with periodStream: BehaviorRelay<Period>) {
        
        let viewModel = PeriodSelectViewModel(
            navigation: self,
            usecase: CalendarUsecase(periodStream: periodStream),
            periodStream: periodStream
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
    
    func pushGoalDetailViewController(with goal: Goal) {
        
        let viewModel = GoalDetailViewModel(navigation: self, goal: goal)
        let viewController = GoalDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func popGoalDetailViewController() {
        navigationController.popViewController(animated: true)
    }
    
    func pushCertPhotoCameraView(with goal: Goal) {
        
        let viewModel = CertPhotoCameraViewModel(navigation: self, goal: goal)
        let viewController = CertPhotoCameraViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func popCertPhotoCameraView() {
        navigationController.popViewController(animated: true)
    }

    func attachPhotoEditCoordinator(_ photoStream: BehaviorRelay<Album.Item>) {
        let photoEditCoordinator = PhotoEditCoordinator(
            navigationController: navigationController,
            photoStream: photoStream,
            photoEditMode: .addNewPhoto
        )
        photoEditCoordinator.parentCoordiantor = self
        children.append(photoEditCoordinator)

        photoEditCoordinator.start()
    }
}
