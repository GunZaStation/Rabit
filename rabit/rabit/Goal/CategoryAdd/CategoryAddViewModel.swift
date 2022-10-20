import Foundation
import RxSwift
import RxCocoa

protocol CategoryAddViewModelInput {
    
    var categoryTitleInput: PublishRelay<String> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var saveButtonDisabled: BehaviorRelay<Bool> { get }
    var closeButtonTouched: PublishRelay<Void> { get }
    var categoryAddResult: PublishRelay<Bool> { get }
}

protocol CategoryAddViewModelOutput {
    
    var titleInputDuplicated: PublishRelay<Bool> { get }
    var titleInputEmpty: PublishRelay<Bool> { get }
}

protocol CategoryAddViewModelProtocol: CategoryAddViewModelInput, CategoryAddViewModelOutput {}

final class CategoryAddViewModel: CategoryAddViewModelProtocol {
    
    let saveButtonTouched = PublishRelay<Void>()
    let closeButtonTouched = PublishRelay<Void>()
    let categoryTitleInput = PublishRelay<String>()
    let categoryTitleOutput = PublishRelay<String>()
    let categoryAddResult = PublishRelay<Bool>()
    
    let saveButtonDisabled = BehaviorRelay<Bool>(value: true)
    let titleInputDuplicated = PublishRelay<Bool>()
    let titleInputEmpty = PublishRelay<Bool>()
    
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
        
        categoryTitleInput
            .map { $0.isEmpty }
            .bind(to: titleInputEmpty)
            .disposed(by: disposeBag)
        
        categoryTitleInput
            .withUnretained(self)
            .map { $0.repository.checkTitleDuplicated(input: $1) }
            .bind(to: titleInputDuplicated)
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(titleInputEmpty.asObservable(), titleInputDuplicated.asObservable())
            .map { $0 || $1 }
            .bind(to: saveButtonDisabled)
            .disposed(by: disposeBag)
        
        closeButtonTouched
            .bind(to: navigation.closeCategoryAddView)
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
                if isSuccess { navigation.closeCategoryAddView.accept(()) }
            })
            .disposed(by: disposeBag)
    }
}
