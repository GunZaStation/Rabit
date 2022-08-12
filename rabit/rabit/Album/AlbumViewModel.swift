import Foundation
import RxSwift

protocol AlbumViewModelInput {
}

protocol AlbumViewModelOutput {
    var albumData: BehaviorSubject<[Album]> { get }
}

protocol AlbumViewModelProtocol: AlbumViewModelInput, AlbumViewModelOutput { }

final class AlbumViewModel: AlbumViewModelProtocol {
    private let albumRepository: AlbumRepositoryProtocol
    
    let albumData: BehaviorSubject<[Album]> = BehaviorSubject(value: [])

    private var disposeBag = DisposeBag()

    init(repository: AlbumRepositoryProtocol) {
        albumRepository = repository

        bind()
    }
}

private extension AlbumViewModel {
    func bind() {
        let fetchedAlbum = albumRepository.fetchAlbumData()

        fetchedAlbum
            .bind(to: albumData)
            .disposed(by: disposeBag)
    }
}
