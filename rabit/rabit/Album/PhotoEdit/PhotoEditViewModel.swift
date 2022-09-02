import Foundation
import RxSwift
import RxRelay

protocol PhotoEditViewModelInput {
    var colorPickerButtonTouched: PublishRelay<Void> { get }
    var stylePickerButtonTouched: PublishRelay<Void> { get }
    var backButtonTouched: PublishRelay<Void> { get }
    var hexPhotoColor: BehaviorRelay<String> { get }
}

protocol PhotoEditViewModelOutput {
    var selectedPhotoData: BehaviorSubject<Album.Item> { get }
}

protocol PhotoEditViewModelProtocol: PhotoEditViewModelInput, PhotoEditViewModelOutput { }

final class PhotoEditViewModel: PhotoEditViewModelProtocol {
    let colorPickerButtonTouched = PublishRelay<Void>()
    let stylePickerButtonTouched = PublishRelay<Void>()
    let backButtonTouched = PublishRelay<Void>()
    let hexPhotoColor: BehaviorRelay<String>
    let selectedPhotoData = BehaviorSubject<Album.Item>(
        value: Album.Item(
            categoryTitle: "",
            goalTitle: "",
            imageData: Data(),
            date: Date(),
            color: "")
    )

    private var disposeBag = DisposeBag()

    init(
        selectedData: Album.Item,
        navigation: PhotoEditNavigation
    ) {
        selectedPhotoData.onNext(selectedData)
        hexPhotoColor = BehaviorRelay<String>(value: selectedData.color)
        bind(to: navigation)
    }
}

private extension PhotoEditViewModel {
    func bind(to navigation: PhotoEditNavigation) {
        colorPickerButtonTouched
            .withUnretained(self)
            .map { viewModel, _ in
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

        hexPhotoColor.withLatestFrom(selectedPhotoData)
            .withUnretained(self)
            .map { viewModel, photoData in
                Album.Item(
                    categoryTitle: photoData.categoryTitle,
                    goalTitle: photoData.goalTitle,
                    imageData: photoData.imageData,
                    date: photoData.date,
                    color: viewModel.hexPhotoColor.value
                )
            }
            .bind(to: selectedPhotoData)
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
}
