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

        let imageSize = CGSize(
            width: bounds.width - 20,
            height: bounds.width - 20
        )

        DispatchQueue.global(qos: .userInteractive).async {
            guard let downsampledCGImage = photo.imageData
                .toDownsampledCGImage(pointSize: imageSize, scale: 2.0) else { return }
            let image = UIImage(cgImage: downsampledCGImage)

            DispatchQueue.main.async {
                self.thumbnailPictureView.image = image.overlayText(of: photo)
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
