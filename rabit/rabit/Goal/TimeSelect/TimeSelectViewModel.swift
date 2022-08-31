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
    var selectedTime: PublishRelay<CertifiableTime> { get }
}

final class TimeSelectViewModel: TimeSelectViewModelInput, TimeSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartTime = PublishRelay<Date>()
    let selectedEndTime = PublishRelay<Date>()
    let selectedTime = PublishRelay<CertifiableTime>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation) {
        bind(to: navigation)
    }
    
    func bind(to navigation: GoalNavigation) {
        
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
            .bind(to: selectedTime)
            .disposed(by: disposeBag)
    }
}
