import Foundation
import RxSwift
import RxRelay

protocol TimeSelectViewModelInput {
    
    var closingViewRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var selectedStartTime: PublishRelay<Double> { get }
    var selectedEndTime: PublishRelay<Double> { get }
    var selectedDays: BehaviorRelay<Set<Day>> { get }
    var viewDidLoad: PublishRelay<Void> { get }
}

protocol TimeSelectViewModelOutput {
    var saveButtonEnabled: PublishRelay<Bool> { get }
    var selectedTime: BehaviorRelay<CertifiableTime> { get }
    var presetDays: Observable<[Day]> { get }
}

final class TimeSelectViewModel: TimeSelectViewModelInput, TimeSelectViewModelOutput {
    
    let viewDidLoad = PublishRelay<Void>()
    let closingViewRequested = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let selectedStartTime = PublishRelay<Double>()
    let selectedEndTime = PublishRelay<Double>()
    let selectedTime: BehaviorRelay<CertifiableTime>
    let selectedDays = BehaviorRelay<Set<Day>>(value: [])
    let presetDays = Observable.of(Day.allCases)
    let saveButtonEnabled = PublishRelay<Bool>()
    
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
        
        viewDidLoad
            .withLatestFrom(timeStream) {
                Double($1.start.toSeconds())
            }
            .bind(to: selectedStartTime)
            .disposed(by: disposeBag)

        viewDidLoad
            .withLatestFrom(timeStream) {
                Double($1.end.toSeconds())
            }
            .bind(to: selectedEndTime)
            .disposed(by: disposeBag)
        
        timeStream
            .map { $0.days.set }
            .bind(to: selectedDays)
            .disposed(by: disposeBag)
        
        selectedDays
            .map { !$0.isEmpty }
            .bind(to: saveButtonEnabled)
            .disposed(by: disposeBag)
        
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
