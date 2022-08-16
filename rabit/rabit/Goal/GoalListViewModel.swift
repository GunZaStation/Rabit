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
    
    weak var navigation: GoalNavigation?
    
    private let repository: GoalListRepository
    private let disposeBag = DisposeBag()
    
    init(repository: GoalListRepository = GoalListRepository()) {
        self.repository = repository
        
        bind()
    }
    
    private func bind() {
        
        categoryAddButtonTouched
            .withUnretained(self)
            .bind(onNext: { viewModel, _ in
                viewModel.navigation?.showCategoryAddView()
            })
            .disposed(by: disposeBag)
        
        requestGoalList
            .withUnretained(self)
            .compactMap { viewModel, _ in
                viewModel.repository.fetchGoalListData()
            }
            .bind(to: goalList)
            .disposed(by: disposeBag)
    }
}
