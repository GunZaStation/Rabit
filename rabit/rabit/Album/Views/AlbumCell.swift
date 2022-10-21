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
        let serialQueue = DispatchQueue(label: "Serial_Queue")

        let imageSize = CGSize(
            width: bounds.width - 20,
            height: bounds.width - 20
        )

        serialQueue.async {
            let image = photo.imageData.toDownsampledImage(pointSize: imageSize, scale: 2.0)
            let scale = (image?.size.width ?? 0) / imageSize.width

            DispatchQueue.main.async {
                self.thumbnailPictureView.image = image?.overlayText(of: photo, scale: scale)
            }
        }
    }
}

private extension AlbumCell {
    // MARK: - Setup UI
    func setupViews() {
        addSubview(thumbnailPictureView)

        thumbnailPictureView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.trailing.equalToSuperview().inset(10)
        }
    }
}
