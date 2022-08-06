import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ThumbnailPictureViewController: UIViewController {
    private let thumbnailPictureCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var imgData = BehaviorRelay(value: [Data]())
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupThumbnailPictureCollectionView()
        setupViews()
        imgData.accept([])
        bind()
    }

    func update(with imageData: [Data]) {
        imgData.accept(imageData)
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailPictureCollectionView.reloadSections([0])
        }
    }
}

private extension ThumbnailPictureViewController {
    // MARK: - Setup UI
    func setupViews() {
        view.addSubview(thumbnailPictureCollectionView)

        thumbnailPictureCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    func setupThumbnailPictureCollectionView() {
        let screenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()

        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: screenSize.width - 100, height: screenSize.width - 100)
        layout.scrollDirection = .horizontal

        thumbnailPictureCollectionView.collectionViewLayout = layout

        thumbnailPictureCollectionView.register(
            ThumbnailPictureCell.self,
            forCellWithReuseIdentifier: ThumbnailPictureCell.identifier
        )
    }
    
    func bind() {
        imgData.asObservable()
            .bind(to: thumbnailPictureCollectionView.rx.items(
                    cellIdentifier: ThumbnailPictureCell.identifier,
                    cellType: ThumbnailPictureCell.self
            )) { _, item, cell in
                cell.configure(with: item)
            }
            .disposed(by: disposeBag)
    }
}
