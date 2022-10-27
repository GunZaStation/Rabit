import Foundation
import RxSwift
import RxRelay

protocol ViewModelProtocol { }

protocol AlbumViewModelInput {
    var requestAlbumData: PublishRelay<Void> { get }
    var photoSelected: BehaviorRelay<Album.Item> { get }
    var indexSelected: PublishRelay<IndexPath> { get }
    var showNextViewRequested: PublishRelay<Void> { get }
}

protocol AlbumViewModelOutput {
    var albumData: BehaviorRelay<[Album]> { get }
}

protocol AlbumViewModelProtocol: AlbumViewModelInput, AlbumViewModelOutput, ViewModelProtocol { }

final class AlbumViewModel: AlbumViewModelProtocol {
    private let albumRepository: AlbumRepositoryProtocol

    let requestAlbumData = PublishRelay<Void>()
    let photoSelected = BehaviorRelay<Album.Item>(value: Album.Item())
    let indexSelected = PublishRelay<IndexPath>()
    let showNextViewRequested = PublishRelay<Void>()

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

        showNextViewRequested
            .withUnretained(self) { viewModel, _ in
                viewModel.photoSelected
            }
            .bind(to: navigation.showPhotoEditView)
            .disposed(by: disposeBag)

        navigation.didChangePhoto
            .withLatestFrom(photoSelected)
            .distinctUntilChanged()
            .withLatestFrom(indexSelected) { ($0, $1) }
            .withUnretained(self) { ($0, $1.0, $1.1) }
            .map { viewModel, newData, indexPath in
                var albumData = viewModel.albumData.value
                albumData[indexPath.section].items[indexPath.item] = newData

                return albumData
            }
            .bind(to: albumData)
            .disposed(by: disposeBag)
    }
}
