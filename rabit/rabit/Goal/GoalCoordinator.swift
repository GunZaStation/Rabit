import UIKit
import RxSwift
import RxRelay

protocol GoalNavigation {
    
    var didTapCategoryAddButton: PublishRelay<Void> { get }
    var didTapCloseCategoryAddButton: PublishRelay<Void> { get }
    var didTapGoalAddButton: PublishRelay<Category> { get }
    var didTapCloseGoalAddViewButton: PublishRelay<Void> { get }
    var didTapPeriodSelectTextField: PublishRelay<BehaviorRelay<Period>> { get }
    var didTapClosePeriodSelectButton: PublishRelay<Void> { get }
    var didTapTimeSelectTextField: PublishRelay<BehaviorRelay<CertifiableTime>> { get }
    var didTapCloseTimeSelectButton: PublishRelay<Void> { get }
    var didTapGoal: PublishRelay<Goal> { get }
    var didTapCloseGoalDetailButton: PublishRelay<Void> { get }
    var didTapCertPhotoCameraButton: PublishRelay<Goal> { get }
    var didTapCloseCertPhotoCameraButton: PublishRelay<Void> { get }
    var didTakeCertPhoto: PublishRelay<BehaviorRelay<Photo>> { get }
}

final class GoalCoordinator: Coordinator, GoalNavigation {

    weak var parentCoordiantor: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    let didTapCategoryAddButton = PublishRelay<Void>()
    let didTapCloseCategoryAddButton = PublishRelay<Void>()
    let didTapGoalAddButton = PublishRelay<Category>()
    let didTapCloseGoalAddViewButton = PublishRelay<Void>()
    let didTapPeriodSelectTextField = PublishRelay<BehaviorRelay<Period>>()
    let didTapClosePeriodSelectButton = PublishRelay<Void>()
    let didTapTimeSelectTextField = PublishRelay<BehaviorRelay<CertifiableTime>>()
    let didTapCloseTimeSelectButton = PublishRelay<Void>()
    let didTapGoal = PublishRelay<Goal>()
    let didTapCloseGoalDetailButton = PublishRelay<Void>()
    let didTapCertPhotoCameraButton = PublishRelay<Goal>()
    let didTapCloseCertPhotoCameraButton = PublishRelay<Void>()
    let didTakeCertPhoto = PublishRelay<BehaviorRelay<Photo>>()

    private let disposeBag = DisposeBag()

    init() {
        self.navigationController = UINavigationController()
        self.navigationController.view.backgroundColor = .systemBackground
    }
    
    private func bind() {
        
        didTapCategoryAddButton
            .bind(onNext: presentCategoryAddViewController)
            .disposed(by: disposeBag)
        
        didTapCloseCategoryAddButton
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: false)
            })
            .disposed(by: disposeBag)
        
        didTapGoalAddButton
            .bind(onNext: presentGoalAddViewController)
            .disposed(by: disposeBag)
        
        didTapCloseGoalAddViewButton
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: true)
            })
            .disposed(by: disposeBag)
        
        didTapPeriodSelectTextField
            .bind(onNext: presentPeriodSelectViewController)
            .disposed(by: disposeBag)
        
        didTapClosePeriodSelectButton
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: false)
            })
            .disposed(by: disposeBag)
        
        didTapTimeSelectTextField
            .bind(onNext: presentTimeSelectViewController)
            .disposed(by: disposeBag)
        
        didTapCloseTimeSelectButton
            .withUnretained(self)
            .bind(onNext: { coordinator, _ in
                coordinator.dismissCurrentView(animated: false)
            })
            .disposed(by: disposeBag)
        
        didTapGoal
            .bind(onNext: pushGoalDetailViewController)
            .disposed(by: disposeBag)
        
        didTapCloseGoalDetailButton
            .bind(onNext: popGoalDetailViewController)
            .disposed(by: disposeBag)
        
        didTapCertPhotoCameraButton
            .bind(onNext: pushCertPhotoCameraView)
            .disposed(by: disposeBag)
        
        didTapCloseCertPhotoCameraButton
            .bind(onNext: popCertPhotoCameraView)
            .disposed(by: disposeBag)
        
        didTakeCertPhoto
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
        let repository = GoalListRepository()
        let viewModel = GoalListViewModel(
            repository: repository,
            navigation: self
        )
        let viewController = GoalListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func presentCategoryAddViewController() {

        let repository = CategoryAddRepository()
        let viewModel = CategoryAddViewModel(
            navigation: self,
            repository: repository
        )
        let viewController = CategoryAddViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overFullScreen
        navigationController.present(viewController, animated: false)
    }
    
    func dismissCurrentView(animated: Bool) {
        
        navigationController.presentedViewController?.dismiss(animated: animated)
    }
    
    func presentGoalAddViewController(category: Category) {

        let repository = GoalAddRepository(category: category)
        let viewModel = GoalAddViewModel(navigation: self, category: category, repository: repository)
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
        
        let repository = AlbumRepository()
        let viewModel = CertPhotoCameraViewModel(
            navigation: self,
            goal: goal,
            repository: repository
        )
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
            photoEditMode: .add
        )

        addChild(photoEditCoordinator)
        photoEditCoordinator.start()
    }
}
