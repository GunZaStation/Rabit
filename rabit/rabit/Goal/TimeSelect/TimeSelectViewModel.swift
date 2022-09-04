import Foundation
import RxSwift
import RxRelay

protocol TimeSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol TimeSelectViewModelOutput {
    
    var selectedStartTime: PublishRelay<Date> { get }
    var selectedEndTime: PublishRelay<Date> { get }
}

final class TimeSelectViewModel: TimeSelectViewModelInput, TimeSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartTime = PublishRelay<Date>()
    let selectedEndTime = PublishRelay<Date>()
    
    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        with timeStream: BehaviorRelay<CertifiableTime>
    ) {
        bind(to: navigation, with: timeStream)
    }
    
    func bind(
        to navigation: GoalNavigation,
        with timeStream: BehaviorRelay<CertifiableTime>
    ) {
        
        closingViewRequested
            .bind(to: navigation.closePeriodSelectView)
            .disposed(by: disposeBag)
        
        let time = Observable.combineLatest(
                        selectedStartTime.asObservable(),
                        selectedEndTime.asObservable()
                    )
                    .map { CertifiableTime(start: $0, end: $1) }
                    .share()
        
        saveButtonTouched
            .withLatestFrom(time)
            .bind(to: timeStream)
            .disposed(by: disposeBag)
    }
}
