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
    weak var navigation: GoalNavigation?
    
    private let disposeBag = DisposeBag()
    
    init() {
        bind()
    }
    
    private func bind() {
        
        input.categoryTitle
            .bind(to: output.categoryTitle)
            .disposed(by: disposeBag)
        
        output.categoryTitle
            .bind(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
    }
}
