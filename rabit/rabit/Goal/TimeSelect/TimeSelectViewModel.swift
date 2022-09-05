import Foundation
import RxSwift
import RxRelay

protocol TimeSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var selectedStartTime: PublishRelay<Double> { get }
    var selectedEndTime: PublishRelay<Double> { get }
}

protocol TimeSelectViewModelOutput {
    var selectedTime: PublishRelay<CertifiableTime> { get }
}

final class TimeSelectViewModel: TimeSelectViewModelInput, TimeSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartTime = PublishRelay<Double>()
    let selectedEndTime = PublishRelay<Double>()
    let selectedTime = PublishRelay<CertifiableTime>()
    
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
        
        Observable
            .combineLatest(selectedStartTime.asObservable(), selectedEndTime.asObservable())
            .map { CertifiableTime(start: Int($0), end: Int($1)) }
            .bind(to: selectedTime)
            .disposed(by: disposeBag)
        
        saveButtonTouched
            .withLatestFrom(selectedTime)
            .bind(to: timeStream)
            .disposed(by: disposeBag)
    }
}
