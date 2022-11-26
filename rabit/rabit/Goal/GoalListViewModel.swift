import Foundation
import RxSwift
import RxCocoa

protocol GoalListViewModelInput {
    
    var requestGoalList: PublishRelay<Void> { get }
    var categoryAddButtonTouched: PublishRelay<Void> { get }
    var goalAddButtonTouched: PublishRelay<Category> { get }
    var showGoalDetailView: PublishRelay<Goal> { get }
    var cellMenuButtonTapped: PublishRelay<Goal> { get }
}

protocol GoalListViewModelOutput {
    
    var goalList: PublishRelay<[Category]> { get }
}

protocol GoalListViewModelProtocol: GoalListViewModelInput, GoalListViewModelOutput {}

final class GoalListViewModel: GoalListViewModelProtocol {
    
    let requestGoalList = PublishRelay<Void>()
    let categoryAddButtonTouched = PublishRelay<Void>()
    let goalAddButtonTouched = PublishRelay<Category>()
    let cellMenuButtonTapped = PublishRelay<Goal>()
    let goalList = PublishRelay<[Category]>()
    let showGoalDetailView = PublishRelay<Goal>()
    
    private let repository: GoalListRepository
    private let disposeBag = DisposeBag()
    
    init(repository: GoalListRepository = GoalListRepository(),
         navigation: GoalNavigation) {
        self.repository = repository

        bind()
        bind(to: navigation)
    }
}

private extension GoalListViewModel {
    
    func bind() {
        
        requestGoalList
            .withUnretained(self)
            .flatMapLatest { viewModel, _ in
                viewModel.repository.fetchGoalListData()
            }
            .bind(to: goalList)
            .disposed(by: disposeBag)
        
        cellMenuButtonTapped
            .bind(to: showActionSheetMenu)
            .disposed(by: disposeBag)
    }
    
    func bind(to navigation: GoalNavigation) {
        
        categoryAddButtonTouched
            .bind(to: navigation.didTapCategoryAddButton)
            .disposed(by: disposeBag)
        
        goalAddButtonTouched
            .bind(to: navigation.didTapGoalAddButton)
            .disposed(by: disposeBag)
        
        navigation.didTapCloseCategoryAddButton
            .bind(to: requestGoalList)
            .disposed(by: disposeBag)
        
        navigation.didTapCloseGoalAddViewButton
            .bind(to: requestGoalList)
            .disposed(by: disposeBag)
        
        showGoalDetailView
            .bind(to: navigation.didTapGoal)
            .disposed(by: disposeBag)
    }
}
