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

        viewModel?.requestAlbumData.accept(())
    }
}

private extension AlbumViewController {
    // MARK: - Setup UI
    func setupViews() {
        setAttributes()
        view.addSubview(albumCollectionView)

        albumCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }

    func setAttributes() {
        view.backgroundColor = .white
    }

    func setupAlbumCollectionView() {
        let layout = CompositionalLayoutFactory.shared.create(
            widthFraction: 1.0,
            heightFraction: 0.32,
            groupWidthFraction: 0.65,
            requireHeader: true,
            headerWidth: UIScreen.main.bounds.width,
            headerHeight: 50.0,
            enableScrolling: true,
            sectionHandler: getFocusedCellIndex
        )

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

            let itemData = dataSource.sectionModels[indexPath.section].items[indexPath.item]

            cell.configure(with: itemData)
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

            let headerTitle = dataSource.sectionModels[indexPath.section].categoryTitle
            header.configure(with: headerTitle)

            return header
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<Album>(
            configureCell: configureCell,
            configureSupplementaryView: configureHeaderView
        )

        return dataSource
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.albumData
            .bind(to: albumCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        albumCollectionView.rx.itemSelected
            .bind(to: viewModel.indexSelected)
            .disposed(by: disposeBag)

        albumCollectionView.rx.itemSelected
            .map { ($0, UICollectionView.ScrollPosition.centeredHorizontally, true) }
            .bind(onNext: albumCollectionView.scrollToItem(at:at:animated:))
            .disposed(by: disposeBag)

        albumCollectionView.rx.modelSelected(Album.Item.self)
            .bind(to: viewModel.photoSelected)
            .disposed(by: disposeBag)

        albumCollectionView.rx.itemSelected
            .map { _ in }
            .bind(to: viewModel.showNextViewRequested)
            .disposed(by: disposeBag)
    }

    func getFocusedCellIndex(
        items: [NSCollectionLayoutVisibleItem],
        offset: CGPoint,
        environment: NSCollectionLayoutEnvironment
    ) {
        items.forEach { item in
            guard item.representedElementKind != UICollectionView.elementKindSectionHeader else { return }
            let cellWidth = environment.container.contentSize.width
            let distanceFromCenter = abs((item.frame.midX - offset.x) - cellWidth / 2.0)

            let minScale: CGFloat = 0.7
            let maxScale: CGFloat = 1.0
            let scale = max(maxScale - (distanceFromCenter / cellWidth), minScale)

            item.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
