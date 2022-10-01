import Foundation
import RxSwift
import RxCocoa

protocol GoalListViewModelInput {
    
    var requestGoalList: PublishRelay<Void> { get }
    var categoryAddButtonTouched: PublishRelay<Void> { get }
    var goalAddButtonTouched: PublishRelay<Category> { get }
}

protocol GoalListViewModelOutput {
    
    var goalList: PublishRelay<[Category]> { get }
}

final class GoalListViewModel: GoalListViewModelInput, GoalListViewModelOutput {
    
    let requestGoalList = PublishRelay<Void>()
    let categoryAddButtonTouched = PublishRelay<Void>()
    let goalAddButtonTouched = PublishRelay<Category>()
    let goalList = PublishRelay<[Category]>()
    
    private let repository: GoalListRepository
    private let disposeBag = DisposeBag()
    
    init(repository: GoalListRepository = GoalListRepository(),
         navigation: GoalNavigation) {
        self.repository = repository
        
        bind(to: navigation)
    }
}

private extension GoalListViewModel {
    
    func bind(to navigation: GoalNavigation) {
        
        categoryAddButtonTouched
            .bind(to: navigation.showCategoryAddView)
            .disposed(by: disposeBag)
        
        goalAddButtonTouched
            .bind(to: navigation.showGoalAddView)
            .disposed(by: disposeBag)
        
        requestGoalList
            .withUnretained(self)
            .flatMapLatest { viewModel, _ in
                viewModel.repository.fetchGoalListData()
            }
            .bind(to: goalList)
            .disposed(by: disposeBag)
        
        navigation.closeCategoryAddView
            .bind(to: requestGoalList)
            .disposed(by: disposeBag)
    }
}
