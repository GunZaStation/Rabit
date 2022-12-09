import Foundation
import RxSwift
import RxCocoa

protocol GoalListViewModelInput {
    
    var requestGoalList: PublishRelay<Void> { get }
    var categoryAddButtonTouched: PublishRelay<Void> { get }
    var goalAddButtonTouched: PublishRelay<Category> { get }
    var showGoalDetailView: PublishRelay<Goal> { get }
    var cellMenuButtonTapped: PublishRelay<Goal> { get }
    var deleteGoal: PublishRelay<Goal> { get }
}

protocol GoalListViewModelOutput {
    
    var goalList: PublishRelay<[Category]> { get }
    var showActionSheetMenu: PublishRelay<Goal> { get }
    var showAlert: PublishRelay<String> { get }
}

protocol GoalListViewModelProtocol: GoalListViewModelInput, GoalListViewModelOutput {}

final class GoalListViewModel: GoalListViewModelProtocol {
    
    let requestGoalList = PublishRelay<Void>()
    let categoryAddButtonTouched = PublishRelay<Void>()
    let goalAddButtonTouched = PublishRelay<Category>()
    let cellMenuButtonTapped = PublishRelay<Goal>()
    let deleteGoal = PublishRelay<Goal>()
    
    let goalList = PublishRelay<[Category]>()
    let showGoalDetailView = PublishRelay<Goal>()
    let showActionSheetMenu = PublishRelay<Goal>()
    let showAlert = PublishRelay<String>()
    
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
        
        let deleteGoalResult =  deleteGoal
            .withUnretained(self)
            .flatMapLatest { viewModel, goal in
                viewModel.repository.deleteGoal(goal)
            }
            .share()

        deleteGoalResult
            .withUnretained(self)
            .bind(onNext: { viewModel, result in
                switch result {
                case .success(let goal):
                    viewModel.showAlert.accept("\(goal.title) 목표 삭제 성공")
                    viewModel.requestGoalList.accept(())
                case .failure(let error):
                    viewModel.showAlert.accept("목표 삭제 실패\n\(error)")
                }
            })
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
