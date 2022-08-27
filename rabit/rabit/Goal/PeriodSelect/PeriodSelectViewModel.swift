import Foundation
import RxSwift
import RxRelay


protocol PeriodSelectViewModelInput {
    
    var dimmedViewTouched: PublishRelay<Void> { get }
}
final class PeriodSelectViewModel: PeriodSelectViewModelInput {
    
    let dimmedViewTouched = PublishRelay<Void>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation) {
        bind(to: navigation)
    }
    
    func bind(to navigation: GoalNavigation) {
        
        dimmedViewTouched
            .bind(to: navigation.closePeriodSelectView)
            .disposed(by: disposeBag)
    }
}
