import Foundation
import RxSwift
import RxCocoa

protocol GoalListViewModelInput {

    var requestGoalList: PublishRelay<Void> { get }
    var categoryAddButtonTouched: PublishRelay<Void> { get }
}

protocol GoalListViewModelOutput {
    
    var goalList: PublishRelay<[Goal]> { get }
}

final class GoalListViewModel: GoalListViewModelInput, GoalListViewModelOutput {
    
    let requestGoalList = PublishRelay<Void>()
    let categoryAddButtonTouched = PublishRelay<Void>()
    let goalList = PublishRelay<[Goal]>()
    
    private let repository: GoalListRepository
    private let disposeBag = DisposeBag()
    
    init(repository: GoalListRepository = GoalListRepository(),
         navigation: GoalNavigation) {
        self.repository = repository
        
        bind(navigation: navigation)
    }
    
    private func bind(navigation: GoalNavigation) {
        
        categoryAddButtonTouched
            .bind(to: navigation.showCategoryAddView)
            .disposed(by: disposeBag)
        
        requestGoalList
            .withUnretained(self)
            .flatMapLatest { viewModel, _ in
                viewModel.repository.fetchGoalListData()
            }
            .bind(to: goalList)
            .disposed(by: disposeBag)        
    }
}
