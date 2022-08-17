import Foundation
import RxSwift
import RxRelay

protocol PhotoEditViewModelInput {
    var colorPickerButtonTouched: PublishRelay<Void> { get }
    var stylePickerButtonTouched: PublishRelay<Void> { get }
    var backButtonTouched: PublishRelay<Void> { get }
}

protocol PhotoEditViewModelOutput {
    var imageData: BehaviorSubject<Data> { get }
}

protocol PhotoEditViewModelProtocol: PhotoEditViewModelInput, PhotoEditViewModelOutput { }

final class PhotoEditViewModel: PhotoEditViewModelProtocol {
    let colorPickerButtonTouched = PublishRelay<Void>()
    let stylePickerButtonTouched = PublishRelay<Void>()
    let backButtonTouched = PublishRelay<Void>()

    let imageData = BehaviorSubject<Data>(value: Data())
    private var disposeBag = DisposeBag()

    init(
        selectedData: Data,
        navigation: PhotoEditNavigation
    ) {
        imageData.onNext(selectedData)

        bind(to: navigation)
    }
}

private extension PhotoEditViewModel {
    func bind(to navigation: PhotoEditNavigation) {
        colorPickerButtonTouched
            .bind(onNext: {
                print("colorPicker")
            })
            .disposed(by: disposeBag)

        stylePickerButtonTouched
            .bind(onNext: {
                print("stylePicker")
            })
            .disposed(by: disposeBag)

        backButtonTouched
            .bind(to: navigation.closePhotoEditView)
            .disposed(by: disposeBag)
    }
}
