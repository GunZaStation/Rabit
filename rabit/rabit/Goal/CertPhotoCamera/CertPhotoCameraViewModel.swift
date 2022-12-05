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

    private let repository: AlbumRepositoryProtocol
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation, goal: Goal, repository: AlbumRepositoryProtocol) {
        self.repository = repository
        
        bind(to: navigation, with: goal)
    }
}

private extension CertPhotoCameraViewModel {
    
    func bind(to navigation: GoalNavigation, with goal: Goal) {

        certPhotoDataInput
            .bind(to: previewPhotoData)
            .disposed(by: disposeBag)
        
        let imageSavedPhoto = nextButtonTouched
            .withLatestFrom(previewPhotoData)
            .withUnretained(self) { ($0, $1) }
            .map { (viewModel, imageData) -> Photo in
                let name = "\(Date().description.prefix(19).replacingOccurrences(of: " ", with: "_")).png"
                viewModel.repository.savePhotoImageData(imageData, name: name)
                
                var photo = Photo.init(
                    categoryTitle: goal.category,
                    goalTitle: goal.title,
                    imageName: name
                )
                photo.imageData = imageData

                return photo
            }
        
        imageSavedPhoto
            .map(BehaviorRelay.init)
            .bind(to: navigation.didTakeCertPhoto)
            .disposed(by: disposeBag)
    }
}
