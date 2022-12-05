import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

typealias AlbumSectionType = AnimatableSectionModel<Album, Photo>
typealias AlbumDataSource = RxCollectionViewSectionedAnimatedDataSource<AlbumSectionType>

final class AlbumViewController: UIViewController {
    private let albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var dataSource: AlbumDataSource = initializeDataSource()

    private var disposeBag = DisposeBag()

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

    func initializeDataSource() -> AlbumDataSource {
        return AlbumDataSource(
            animationConfiguration: AnimationConfiguration(
                insertAnimation: .right,
                reloadAnimation: .fade,
                deleteAnimation: .left
            ),
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView,
            canMoveItemAtIndexPath: canMoveItemAtIndexPath
        )
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        viewModel.albumData
            .map { albumArray in
                albumArray
                    .map { AlbumSectionType(model: $0, items: $0.items) }
            }
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

        albumCollectionView.rx.prefetchItems
            .withUnretained(self)
            .bind { viewController, indexPaths in
                indexPaths.forEach {
                    viewController.prefetchItemImage(of: $0)
                }
            }
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

    func prefetchItemImage(of indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }

        let prefetchTarget = viewModel.albumData.value[indexPath.section].items[indexPath.item]
        let cacheKey = "\(prefetchTarget.uuid)\(prefetchTarget.style)\(prefetchTarget.color)\(AlbumCell.identifier)" as NSString

        guard ImageCacheManager.shared.object(forKey: cacheKey) == nil else { return }

        let imageSize = CGSize(
            width: view.bounds.width - 20,
            height: view.bounds.width - 20
        )

        DispatchQueue.global().async {
            guard let imageData = prefetchTarget.imageData,
                  let downsampledCGImage = imageData
                        .toDownsampledCGImage(
                            pointSize: imageSize,
                            scale: 0.5
                        ) else { return }

            let downsampledUIImage = UIImage(cgImage: downsampledCGImage)

            DispatchQueue.main.async {
                let textOverlayedImage = downsampledUIImage.overlayText(of: prefetchTarget) ?? UIImage()
                ImageCacheManager.shared.setObject(textOverlayedImage, forKey: cacheKey)
            }
        }
    }
}

// MARK: - Data Source Configuration
private extension AlbumViewController {
    var configureCell: AlbumDataSource.ConfigureCell {
        return { (dataSource, collectionView, indexPath, item) in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlbumCell.identifier,
                for: indexPath
            ) as? AlbumCell else { return UICollectionViewCell() }

            let itemData = dataSource.sectionModels[indexPath.section].items[indexPath.item]
            cell.configure(with: itemData)
            return cell
        }
    }

    var configureSupplementaryView: AlbumDataSource.ConfigureSupplementaryView {
        return { (dataSource, collectionView, kind, indexPath) in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: AlbumHeaderView.identifier,
                      for: indexPath
                  ) as? AlbumHeaderView else {
                return UICollectionReusableView()
            }
            let headerTitle = dataSource.sectionModels[indexPath.section].model.categoryTitle
            header.configure(with: headerTitle)

            return header
        }
    }

    var canMoveItemAtIndexPath: AlbumDataSource.CanMoveItemAtIndexPath {
        return { _, _ in return false }
    }
}
