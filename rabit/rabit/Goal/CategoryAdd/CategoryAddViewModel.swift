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

        categoryTitleInput
            .withUnretained(self)
            .map { viewModel, titleInput in
                let isDuplicated = viewModel.repository.checkTitleDuplicated(input: titleInput)
                let isEmpty = titleInput.isEmpty
                return (viewModel, isDuplicated, isEmpty)
            }
            .bind(onNext: { viewModel, isDuplicated, isEmpty in
                viewModel.saveButtonDisabled.accept((isEmpty || isDuplicated))
                viewModel.warningLabelHidden.accept(!isDuplicated)
            })
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
                guard isSuccess else { return }
                navigation.closeCategoryAddView.accept(())
            })
            .disposed(by: disposeBag)
    }
}
