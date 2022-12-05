import Foundation
import RxSwift
import RxRelay

protocol CertPhotoCameraViewModelInput {
    
    var certPhotoDataInput: PublishRelay<Data> { get }
    var nextButtonTouched: PublishRelay<Void> { get }
    var photoSaveResult: PublishRelay<Bool> { get }
}
protocol CertPhotoCameraViewModelOutput {
    
    var previewPhotoData: PublishRelay<Data> { get }
}

protocol CertPhotoCameraViewModelProtocol: CertPhotoCameraViewModelInput, CertPhotoCameraViewModelOutput {}

final class CertPhotoCameraViewModel: CertPhotoCameraViewModelProtocol {
    
    let certPhotoDataInput = PublishRelay<Data>()
    let nextButtonTouched = PublishRelay<Void>()
    let photoSaveResult = PublishRelay<Bool>()
    
    let previewPhotoData = PublishRelay<Data>()
    
    private var dateInfo: String

    private let repository: AlbumRepositoryProtocol
    
    private let disposeBag = DisposeBag()
    
    init(navigation: GoalNavigation, goal: Goal, repository: AlbumRepositoryProtocol) {
        self.repository = repository
        self.dateInfo = Date().description.prefix(19).replacingOccurrences(of: " ", with: "_")
        
        bind(to: navigation, with: goal)
    }
}

private extension CertPhotoCameraViewModel {
    
    func bind(to navigation: GoalNavigation, with goal: Goal) {

        certPhotoDataInput
            .bind(to: previewPhotoData)
            .disposed(by: disposeBag)
        
        nextButtonTouched
            .withLatestFrom(previewPhotoData)
            .withUnretained(self)
            .flatMapLatest { (viewModel, imageData) -> Single<Bool> in
                viewModel.dateInfo = Date().description.prefix(19).replacingOccurrences(of: " ", with: "_")
                let name = "\(viewModel.dateInfo).png"
                return viewModel.repository.savePhotoImageData(imageData, name: name)
            }
            .bind(to: photoSaveResult)
            .disposed(by: disposeBag)
        
        let imageSavedPhoto = photoSaveResult
            .withLatestFrom(previewPhotoData)
            .withUnretained(self) { (goal.category, goal.title, "\($0.dateInfo).png", $1) }
            .map(Photo.init)
        
        photoSaveResult
            .withLatestFrom(imageSavedPhoto) { ($0, $1) }
            .bind { saveResult, photo in
                guard saveResult == true else { return }
                navigation.didTakeCertPhoto.accept(BehaviorRelay<Photo>(value: photo))
            }
            .disposed(by: disposeBag)
    }
}
