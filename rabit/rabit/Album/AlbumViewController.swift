import UIKit
import SnapKit

final class AlbumViewController: UIViewController {
    private let albumCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    // Mock Data
    private let data: [[UIImage?]] = [
        [UIImage(systemName: "pencil"), UIImage(systemName: "pencil"), UIImage(systemName: "pencil")],
        [UIImage(systemName: "pencil"), UIImage(systemName: "pencil"), UIImage(systemName: "pencil"), UIImage(systemName: "pencil")],
        [UIImage(systemName: "pencil")]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAlbumCollectionView()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true
    }
}

extension AlbumViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumCell.identifier,
            for: indexPath) as? AlbumCell else { return UICollectionViewCell() }

        cell.configure(with: data[indexPath.item])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: AlbumHeaderView.identifier,
                  for: indexPath
              ) as? AlbumHeaderView else {
            return UICollectionReusableView()
        }

        header.configure(with: "2022년 3월 21일")

        return header
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
        let screenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenSize.width, height: screenSize.width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 15
        layout.headerReferenceSize = CGSize(width: screenSize.width, height: 50)
        layout.scrollDirection = .vertical

        albumCollectionView.collectionViewLayout = layout
        albumCollectionView.dataSource = self

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
}
