import UIKit
import SnapKit

final class AlbumCell: UICollectionViewCell {

    private let thumbnailPictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.roundCorners()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    func configure(with photo: Album.Item) {
        thumbnailPictureView.image = UIImage(data: photo.imageData)
    }
}

private extension AlbumCell {
    // MARK: - Setup UI
    func setupViews() {
        addSubview(thumbnailPictureView)

        thumbnailPictureView.snp.makeConstraints { make in
            make.top.leading.equalTo(self).offset(10)
            make.bottom.trailing.equalTo(self).inset(10)
        }
    }
}
