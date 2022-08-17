import Foundation
import RxSwift
import RxRelay

protocol AlbumViewModelInput {
    // 임시적으로 Data 타입을 받도록 설정 (추후 AlbumView에서 보여지는 Cell의 모델 변경 예정)
    var photoSelected: PublishRelay<Data> { get }
}

protocol AlbumViewModelOutput {
    var albumData: BehaviorSubject<[Album]> { get }
}

protocol AlbumViewModelProtocol: AlbumViewModelInput, AlbumViewModelOutput { }

final class AlbumViewModel: AlbumViewModelProtocol {
    private let albumRepository: AlbumRepositoryProtocol

    let photoSelected: PublishRelay<Data> = PublishRelay()
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

        photoSelected
            .bind(onNext: {
                // Coordinator로부터 화면 이동 로직을 받아온 후 수정 예정
                print($0)
            })
            .disposed(by: disposeBag)
    }
}
