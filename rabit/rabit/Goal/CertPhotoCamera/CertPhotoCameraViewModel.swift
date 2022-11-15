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

protocol CertPhotoCameraViewModelProtocol: CertPhotoCameraViewModelInput, CertPhotoCameraViewModelOutput {}

final class CertPhotoCameraViewModel: CertPhotoCameraViewModelProtocol {
    
    let certPhotoDataInput = PublishRelay<Data>()
    let nextButtonTouched = PublishRelay<Void>()
    let previewPhotoData = PublishRelay<Data>()
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation, goal: Goal) {
        bind(to: navigation, with: goal)
    }
}

private extension CertPhotoCameraViewModel {
    
    func bind(to navigation: GoalNavigation, with goal: Goal) {

        certPhotoDataInput
            .bind(to: previewPhotoData)
            .disposed(by: disposeBag)
        
        nextButtonTouched
            .withLatestFrom(previewPhotoData) { (goal.category, goal.title, $1) }
            .map(Photo.init)
            .map(BehaviorRelay.init)
            .bind(to: navigation.didTakeCertPhoto)
            .disposed(by: disposeBag)
    }
}
