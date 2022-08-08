import UIKit
import SnapKit

final class AlbumCell: UICollectionViewCell {
    static let identifier = String(describing: AlbumCell.self)

    private let thumbNailViewController = ThumbnailPictureViewController()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    func configure(with imageData: [Data]) {
        thumbNailViewController.update(with: imageData)
    }
}

private extension AlbumCell {
    // MARK: - Setup UI
    func setupViews() {
        clipsToBounds = true
        addSubview(thumbNailViewController.view)

        thumbNailViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
