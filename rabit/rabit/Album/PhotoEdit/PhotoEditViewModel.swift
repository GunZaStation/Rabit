import Foundation
import RxSwift
import RxRelay

protocol PhotoEditViewModelInput {
    var selectColorButtonTouched: PublishRelay<Void> { get }
    var selectStyleButtonTouched: PublishRelay<Void> { get }
    var backButtonTouched: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var hexPhotoColor: BehaviorRelay<String> { get }
    var albumUpdateResult: PublishRelay<Bool> { get }
}

protocol PhotoEditViewModelOutput {
    var selectedPhotoData: BehaviorRelay<Album.Item> { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
}

protocol PhotoEditViewModelProtocol: PhotoEditViewModelInput, PhotoEditViewModelOutput { }

final class PhotoEditViewModel: PhotoEditViewModelProtocol {
    let selectColorButtonTouched = PublishRelay<Void>()
    let selectStyleButtonTouched = PublishRelay<Void>()
    let backButtonTouched = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let hexPhotoColor: BehaviorRelay<String>
    let albumUpdateResult = PublishRelay<Bool>()

    let saveButtonState = BehaviorRelay<Bool>(value: false)
    let selectedPhotoData: BehaviorRelay<Album.Item>

    private let albumRepository: AlbumRepositoryProtocol

    private var disposeBag = DisposeBag()

    init(
        photoStream: BehaviorRelay<Album.Item>,
        repository: AlbumRepositoryProtocol,
        navigation: PhotoEditNavigation
    ) {
        selectedPhotoData = .init(value: photoStream.value)
        hexPhotoColor = .init(value: photoStream.value.color)
        self.albumRepository = repository

        bind(to: photoStream)
        bind(to: navigation)
    }
}

private extension PhotoEditViewModel {
    func bind(to navigation: PhotoEditNavigation) {
        selectColorButtonTouched
            .withUnretained(self) { viewModel, _ in
                viewModel.hexPhotoColor
            }
            .bind(to: navigation.showColorSelectView)
            .disposed(by: disposeBag)

        selectStyleButtonTouched
            .withUnretained(self) { viewModel, _ in
                viewModel.selectedPhotoData
            }
            .bind(to: navigation.showStyleSelectView)
            .disposed(by: disposeBag)

        backButtonTouched
            .bind(to: navigation.closePhotoEditView)
            .disposed(by: disposeBag)

        albumUpdateResult
            .bind { isSuccess in
                isSuccess ? navigation.didChangePhoto.accept(()) : nil
            }
            .disposed(by: disposeBag)
    }

    func bind(to photoStream: BehaviorRelay<Album.Item>) {
        selectedPhotoData
            .map { $0 != photoStream.value }
            .bind(to: saveButtonState)
            .disposed(by: disposeBag)

        hexPhotoColor
            .withLatestFrom(selectedPhotoData) {
                Album.Item(
                    uuid: $1.uuid,
                    categoryTitle: $1.categoryTitle,
                    goalTitle: $1.goalTitle,
                    imageData: $1.imageData,
                    date: $1.date,
                    color: $0
                )
            }
            .bind(to: selectedPhotoData)
            .disposed(by: disposeBag)

        saveButtonTouched.withLatestFrom(selectedPhotoData)
            .bind(to: photoStream)
            .disposed(by: disposeBag)

        saveButtonTouched.withLatestFrom(selectedPhotoData)
            .withUnretained(self)
            .flatMapLatest { viewModel, data in
                viewModel.albumRepository.updateAlbumData(data)
            }
            .bind(to: albumUpdateResult)
            .disposed(by: disposeBag)
    }
}
