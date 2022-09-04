import Foundation
import RxSwift
import RxRelay

protocol AlbumViewModelInput {
    var requestAlbumData: PublishRelay<Void> { get }
    var photoSelected: PublishRelay<Album.Item> { get }
}

protocol AlbumViewModelOutput {
    var albumData: BehaviorRelay<[Album]> { get }
}

protocol AlbumViewModelProtocol: AlbumViewModelInput, AlbumViewModelOutput { }

final class AlbumViewModel: AlbumViewModelProtocol {
    private let albumRepository: AlbumRepositoryProtocol

    let requestAlbumData = PublishRelay<Void>()
    let photoSelected = PublishRelay<Album.Item>()
    let albumData = BehaviorRelay<[Album]>(value: [])

    private var disposeBag = DisposeBag()

    init(
        repository: AlbumRepositoryProtocol,
        navigation: AlbumNavigation
    ) {
        albumRepository = repository

        bind(to: navigation)
    }
}

private extension AlbumViewModel {
    func bind(to navigation: AlbumNavigation) {

        requestAlbumData
            .withUnretained(self)
            .flatMapLatest { viewModel, _ in
                viewModel.albumRepository.fetchAlbumData()
            }
            .bind(to: albumData)
            .disposed(by: disposeBag)

        photoSelected
            .bind(to: navigation.showPhotoEditView)
            .disposed(by: disposeBag)

        navigation.closePhotoEditView
            .bind(to: requestAlbumData)
            .disposed(by: disposeBag)
    }
}
