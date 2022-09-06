import Foundation
import RxSwift
import RxRelay

protocol PhotoEditViewModelInput {
    var colorPickerButtonTouched: PublishRelay<Void> { get }
    var stylePickerButtonTouched: PublishRelay<Void> { get }
    var backButtonTouched: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
    var hexPhotoColor: BehaviorRelay<String> { get }
}

protocol PhotoEditViewModelOutput {
    var selectedPhotoData: BehaviorRelay<Album.Item> { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
}

protocol PhotoEditViewModelProtocol: PhotoEditViewModelInput, PhotoEditViewModelOutput { }

final class PhotoEditViewModel: PhotoEditViewModelProtocol {
    let colorPickerButtonTouched = PublishRelay<Void>()
    let stylePickerButtonTouched = PublishRelay<Void>()
    let backButtonTouched = PublishRelay<Void>()
    let saveButtonTouched = PublishRelay<Void>()
    let hexPhotoColor: BehaviorRelay<String>
    let saveButtonState = BehaviorRelay<Bool>(value: false)
    let selectedPhotoData: BehaviorRelay<Album.Item>

    private let albumRepository: AlbumRepositoryProtocol

    private var disposeBag = DisposeBag()

    init(
        selectedData: Album.Item,
        repository: AlbumRepositoryProtocol,
        navigation: PhotoEditNavigation
    ) {
        selectedPhotoData = .init(value: selectedData)
        hexPhotoColor = .init(value: selectedData.color)
        self.albumRepository = repository

        bind(to: navigation)
        bind(to: selectedData)
    }
}

private extension PhotoEditViewModel {
    func bind(to navigation: PhotoEditNavigation) {
        colorPickerButtonTouched
            .withUnretained(self) { viewModel, _ in
                viewModel.hexPhotoColor
            }
            .bind(to: navigation.showColorPickerView)
            .disposed(by: disposeBag)

        stylePickerButtonTouched
            .bind(to: navigation.showStylePickerView)
            .disposed(by: disposeBag)

        backButtonTouched
            .bind(to: navigation.closePhotoEditView)
            .disposed(by: disposeBag)

        saveButtonTouched.withLatestFrom(selectedPhotoData)
            .withUnretained(self)
            .bind(onNext: { viewModel, data in
                viewModel.albumRepository.updateAlbumData(data)

                navigation.saveUpdatedPhoto.accept(())
            })
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
    }

    func bind(to selectedData: Album.Item) {
        selectedPhotoData
            .map { $0 != selectedData }
            .bind(to: saveButtonState)
            .disposed(by: disposeBag)
    }
}
