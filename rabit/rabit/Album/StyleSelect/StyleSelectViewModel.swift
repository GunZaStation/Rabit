import Foundation
import RxSwift
import RxRelay

protocol StyleSelectViewModelInput {
    var appliedPhotoWithSelectedStyle: BehaviorRelay<Album.Item> { get }
    var closeStyleSelectRequested: PublishRelay<Void> { get }
    var saveButtonTouched: PublishRelay<Void> { get }
}

protocol StyleSelectViewModelOutput {
    var presetStyles: [Style] { get }
    var saveButtonState: BehaviorRelay<Bool> { get }
}

protocol StyleSelectViewModelProtocol: StyleSelectViewModelInput, StyleSelectViewModelOutput, ViewModelProtocol { }

final class StyleSelectViewModel: StyleSelectViewModelProtocol {
    var appliedPhotoWithSelectedStyle: BehaviorRelay<Photo>
    var closeStyleSelectRequested = PublishRelay<Void>()
    var saveButtonTouched = PublishRelay<Void>()

    var saveButtonState = BehaviorRelay<Bool>(value: false)
    var presetStyles = Style.allCases

    private var disposeBag = DisposeBag()

    init(
        photoStream: BehaviorRelay<Album.Item>,
        navigation: StyleSelectNavigation
    ) {
        appliedPhotoWithSelectedStyle = .init(value: photoStream.value)
        bind(to: photoStream)
        bind(to: navigation)
    }
}

private extension StyleSelectViewModel {
    func bind(to photoStream: BehaviorRelay<Album.Item>) {
        saveButtonTouched
            .withLatestFrom(appliedPhotoWithSelectedStyle)
            .bind(to: photoStream)
            .disposed(by: disposeBag)

        appliedPhotoWithSelectedStyle
            .map { $0.style != photoStream.value.style }
            .bind(to: saveButtonState)
            .disposed(by: disposeBag)
    }

    func bind(to navigation: StyleSelectNavigation) {
        closeStyleSelectRequested
            .bind(to: navigation.closeStyleSelectView)
            .disposed(by: disposeBag)
    }
}
