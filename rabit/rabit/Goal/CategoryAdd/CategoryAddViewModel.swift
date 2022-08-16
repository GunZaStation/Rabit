import Foundation
import RxSwift
import RxCocoa

protocol CategoryAddViewModelInput {
    
    var categoryTitle: PublishRelay<String> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
}

protocol CategoryAddViewModelOutput {

    var categoryTitle: PublishRelay<String> { get }
}

final class CategoryAddViewModel {
    
    struct Input: CategoryAddViewModelInput {
        let saveButtonTouched = PublishRelay<Void>()
        let closeButtonTouched = PublishRelay<Void>()
        let categoryTitle = PublishRelay<String>()
    }
    
    struct Output: CategoryAddViewModelOutput {
        let categoryTitle = PublishRelay<String>()
    }
    
    
    let input = Input()
    let output = Output()
    
    private let disposeBag = DisposeBag()
    
    init(coordinator: GoalCoordinator) {
        bind(coordinator: coordinator)
    }
    
    private func bind(coordinator: GoalCoordinator) {
        
        input.categoryTitle
            .bind(to: output.categoryTitle)
            .disposed(by: disposeBag)
        
        output.categoryTitle
            .bind(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        input.closeButtonTouched
            .bind(to: coordinator.closeCategoryAddView)
            .disposed(by: disposeBag)
    }
}
