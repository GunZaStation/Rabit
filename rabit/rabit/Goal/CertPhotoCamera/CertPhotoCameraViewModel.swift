import Foundation
import RxSwift
import RxRelay

protocol CertPhotoCameraViewModelInput {
    
    var certPhotoDataInput: PublishRelay<Data> { get }
    var nextButtonTouched: PublishRelay<Void> { get }
}
protocol CertPhotoCameraViewModelOutput {
    
    var previewPhotoData: PublishRelay<Data> { get }
}

final class CertPhotoCameraViewModel: CertPhotoCameraViewModelInput, CertPhotoCameraViewModelOutput {
    
    let certPhotoDataInput = PublishRelay<Data>()
    let nextButtonTouched = PublishRelay<Void>()
    let previewPhotoData = PublishRelay<Data>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation, goal: Goal) {
        bind(to: navigation, with: goal)
    }
    
    func bind(to navigation: GoalNavigation, with goal: Goal) {

        certPhotoDataInput
            .bind(to: previewPhotoData)
            .disposed(by: disposeBag)
        
        nextButtonTouched
            .withLatestFrom(previewPhotoData)
            .map { Photo(categoryTitle: goal.category, goalTitle: goal.title, imageData: $0, date: Date(), color: "", style: .none) }
            .map { BehaviorRelay(value: $0) }
            .bind(to: navigation.showPhotoEditView)
            .disposed(by: disposeBag)
    }
}
