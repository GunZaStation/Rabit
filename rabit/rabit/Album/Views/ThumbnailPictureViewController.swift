import UIKit
import SnapKit

final class ThumbnailPictureViewController: UIViewController {
    private let thumbnailPictureCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private var imgData: [UIImage?] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupThumbnailPictureCollectionView()
        setupViews()
    }

    func update(with images: [UIImage?]) {
        imgData = images
        DispatchQueue.main.async { [weak self] in
            self?.thumbnailPictureCollectionView.reloadSections([0])
        }
    }
}

// MARK: - CollectionView datasource methods
extension ThumbnailPictureViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ThumbnailPictureCell.identifier,
            for: indexPath
        ) as? ThumbnailPictureCell else { return UICollectionViewCell() }

        cell.configure(with: imgData[indexPath.item])

        return cell
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
        thumbnailPictureCollectionView.dataSource = self

        thumbnailPictureCollectionView.register(
            ThumbnailPictureCell.self,
            forCellWithReuseIdentifier: ThumbnailPictureCell.identifier
        )
    }
}
