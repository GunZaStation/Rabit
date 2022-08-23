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

    let selectedPhotoData = BehaviorSubject<Album.Item>(value: Album.Item(imageData: Data(), date: Date(), color: ""))
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
            .bind(to: navigation.showColorPickerView)
            .disposed(by: disposeBag)

        stylePickerButtonTouched
            .bind(to: navigation.showStylePickerView)
            .disposed(by: disposeBag)

        backButtonTouched
            .bind(to: navigation.closePhotoEditView)
            .disposed(by: disposeBag)

        Observable.combineLatest(selectedPhotoData, hexPhotoColor).map {
            Album.Item(imageData: $0.imageData, date: $0.date, color: $1)
        }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: selectedPhotoData)
            .disposed(by: disposeBag)
    }
}
