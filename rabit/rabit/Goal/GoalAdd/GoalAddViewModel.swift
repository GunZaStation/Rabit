import Foundation
import RxSwift
import RxRelay

protocol GoalAddViewModelInput {
    
    var saveButtonTouched: PublishRelay<Void> { get }
}

final class GoalAddViewModel: GoalAddViewModelInput {
    
    let saveButtonTouched = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation) {
        bind(to: navigation)
    }
}

private extension GoalAddViewModel {
    
    func bind(to navigation: GoalNavigation) {
        
        saveButtonTouched
            .bind(to: navigation.closeGoalAddView)
            .disposed(by: disposeBag)
    }
}
