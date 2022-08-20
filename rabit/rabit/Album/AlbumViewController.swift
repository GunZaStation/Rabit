import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

typealias DataSource = CollectionViewSectionedDataSource<Album>

final class AlbumViewController: UIViewController {
    private let albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private var disposeBag = DisposeBag()
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Album> = {
        return initializeDataSource()
    }()

    private var viewModel: AlbumViewModelProtocol?

    convenience init(viewModel: AlbumViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAlbumCollectionView()
        setupViews()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
    }
}

private extension AlbumViewController {
    // MARK: - Setup UI
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(albumCollectionView)

        albumCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    func setupAlbumCollectionView() {
        let layout = getCollectionViewLayout()

        albumCollectionView.collectionViewLayout = layout

        albumCollectionView.register(
            AlbumCell.self,
            forCellWithReuseIdentifier: AlbumCell.identifier
        )
        albumCollectionView.register(
            AlbumHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AlbumHeaderView.identifier
        )
    }

    func initializeDataSource() -> RxCollectionViewSectionedReloadDataSource<Album> {
        let configureCell: (DataSource, UICollectionView, IndexPath, Album.Item) -> UICollectionViewCell = { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCell.identifier,
                for: indexPath) as? AlbumCell else { return UICollectionViewCell(
            ) }

            let dataArr = dataSource.sectionModels[indexPath.section].items[0]

            cell.configure(with: dataArr)
            return cell
        }

        let configureHeaderView: (DataSource, UICollectionView, String, IndexPath) -> UICollectionReusableView = { (dataSource, collectionView, kind, indexPath) in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: AlbumHeaderView.identifier,
                      for: indexPath
                  ) as? AlbumHeaderView else {
                return UICollectionReusableView()
            }

            let formatter = DateFormatter()
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy년 MM월 dd일"
            let targetDate = dataSource.sectionModels[indexPath.section].date
            header.configure(with: formatter.string(from: targetDate))

            return header
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<Album>(
            configureCell: configureCell,
            configureSupplementaryView: configureHeaderView
        )

        return dataSource
    }

    func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (section, _) -> NSCollectionLayoutSection? in
            AlbumCollectionCompositionalLayoutFactory.shared.create()
        }
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.albumData
            .bind(to: albumCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        albumCollectionView.rx.modelSelected(Album.Item.self)
            .bind(to: viewModel.photoSelected)
            .disposed(by: disposeBag)
    }
}
