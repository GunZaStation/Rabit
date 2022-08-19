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
        bind(navigation: navigation)
    }
    
    private func bind(navigation: GoalNavigation) {
        
        saveButtonTouched
            .bind(to: navigation.closeGoalAddView)
            .disposed(by: disposeBag)
    }
}
