import Foundation
import RxSwift
import RxRelay

protocol AlbumViewModelInput {
    var photoSelected: PublishRelay<Data> { get }
}

protocol AlbumViewModelOutput {
    var albumData: BehaviorSubject<[Album]> { get }
}

protocol AlbumViewModelProtocol: AlbumViewModelInput, AlbumViewModelOutput { }

final class AlbumViewModel: AlbumViewModelProtocol {
    private let albumRepository: AlbumRepositoryProtocol

    let photoSelected = PublishRelay<Data>()
    let albumData = BehaviorSubject<[Album]>(value: [])

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
        let fetchedAlbum = albumRepository.fetchAlbumData()

        fetchedAlbum
            .bind(to: albumData)
            .disposed(by: disposeBag)

        photoSelected
            .bind(to: navigation.showPhotoEditView)
            .disposed(by: disposeBag)
    }
}
