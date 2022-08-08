import UIKit
import SnapKit

final class ThumbnailPictureCell:  UICollectionViewCell {
    static let identifier = String(describing: ThumbnailPictureCell.self)

    private let thumbnailPictureView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 10
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

    func configure(with imgData: Data) {
        thumbnailPictureView.image = UIImage(data: imgData)
    }
}

private extension ThumbnailPictureCell {
    // MARK: - Setup UI
    func setupViews() {
        addSubview(thumbnailPictureView)

        thumbnailPictureView.snp.makeConstraints { make in
            make.top.leading.equalTo(self).offset(10)
            make.bottom.trailing.equalTo(self).inset(10)
        }
    }
}
