import Foundation
import RxSwift
import RxCocoa

protocol CategoryAddViewModelInput {
    
    var categoryTitleInput: PublishRelay<String> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
}

protocol CategoryAddViewModelOutput {
    
    var categoryTitleOutput: PublishRelay<String> { get }
}

final class CategoryAddViewModel: CategoryAddViewModelInput, CategoryAddViewModelOutput {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let categoryTitleInput = PublishRelay<String>()
    let categoryTitleOutput = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation) {
        bind(navigation: navigation)
    }
    
    private func bind(navigation: GoalNavigation) {
        
        categoryTitleInput
            .bind(to: categoryTitleOutput)
            .disposed(by: disposeBag)
        
        categoryTitleOutput
            .bind(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        closeButtonTouched
            .bind(to: navigation.closeCategoryAddView)
            .disposed(by: disposeBag)
    }
}
