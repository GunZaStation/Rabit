import Foundation
import RxSwift
import RxCocoa

protocol CategoryAddViewModelInput {
    
    var categoryTitleInput: PublishRelay<String> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var categoryAddResult: PublishRelay<Bool> { get }
}

protocol CategoryAddViewModelOutput {

    var saveButtonDisabled: BehaviorRelay<Bool> { get }
    var warningLabelHidden: PublishRelay<Bool> { get }
}

protocol CategoryAddViewModelProtocol: CategoryAddViewModelInput, CategoryAddViewModelOutput {}

final class CategoryAddViewModel: CategoryAddViewModelProtocol {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let categoryTitleInput = PublishRelay<String>()
    let categoryTitleOutput = PublishRelay<String>()
    let categoryAddResult = PublishRelay<Bool>()
    
    let saveButtonDisabled = BehaviorRelay<Bool>(value: true)
    let warningLabelHidden = PublishRelay<Bool>()

    private let disposeBag = DisposeBag()
    private let repository: CategoryAddRepository
    
    init(navigation: GoalNavigation,
         repository: CategoryAddRepository = CategoryAddRepository()) {
        self.repository = repository
        
        bind(to: navigation)
    }
    
}

private extension CategoryAddViewModel {
    
    func bind(to navigation: GoalNavigation) {
        
        let categoryTitleVertification = categoryTitleInput
                                            .withUnretained(self)
                                            .map { viewModel, titleInput -> (Bool, Bool) in
                                                let isDuplicated = viewModel.repository.checkTitleDuplicated(input: titleInput)
                                                let isEmpty = titleInput.isEmpty
                                                return (isDuplicated, isEmpty)
                                            }
                                            .share()
        
        categoryTitleVertification
            .map { $0 || $1 }
            .bind(to: saveButtonDisabled)
            .disposed(by: disposeBag)
        
        categoryTitleVertification
            .map { !$0.0 }
            .bind(to: warningLabelHidden)
            .disposed(by: disposeBag)
        
        closeButtonTouched
            .bind(to: navigation.didTapCloseCategoryAddButton)
            .disposed(by: disposeBag)
        
        saveButtonTouched
            .withLatestFrom(categoryTitleInput)
            .withUnretained(self)
            .flatMapLatest { viewModel, title in
                viewModel.repository.addCategory( Category(title: title))
            }
            .bind(to: categoryAddResult)
            .disposed(by: disposeBag)
        
        categoryAddResult
            .bind(onNext: { isSuccess in
                guard isSuccess else { return }
                navigation.didTapCloseCategoryAddButton.accept(())
            })
            .disposed(by: disposeBag)
    }
}
