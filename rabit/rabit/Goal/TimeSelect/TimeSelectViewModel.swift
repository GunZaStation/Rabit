import Foundation
import RxSwift
import RxRelay

protocol TimeSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var selectedStartTime: PublishRelay<Double> { get }
    var selectedEndTime: PublishRelay<Double> { get }
    var selectedDays: BehaviorRelay<Set<Day>> { get }
}

protocol TimeSelectViewModelOutput {
    var selectedTime: BehaviorRelay<CertifiableTime> { get }
    var presetDays: Observable<[Day]> { get }
}

final class TimeSelectViewModel: TimeSelectViewModelInput, TimeSelectViewModelOutput {
    
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartTime = PublishRelay<Double>()
    let selectedEndTime = PublishRelay<Double>()
    let selectedTime: BehaviorRelay<CertifiableTime>
    let selectedDays = BehaviorRelay<Set<Day>>(value: [])
    let presetDays = Observable.of(Day.allCases)
    
    private let disposeBag = DisposeBag()
    
    init(
        navigation: GoalNavigation,
        with timeStream: BehaviorRelay<CertifiableTime>
    ) {
        self.selectedTime = .init(value: timeStream.value)
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
            .combineLatest( selectedStartTime, selectedEndTime, selectedDays )
            .map { CertifiableTime(start: Int($0), end: Int($1), days: Days($2)) }
            .bind(to: selectedTime)
            .disposed(by: disposeBag)
        
        saveButtonTouched
            .withLatestFrom(selectedTime)
            .bind(to: timeStream)
            .disposed(by: disposeBag)
    }
}
