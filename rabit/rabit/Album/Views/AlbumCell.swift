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
        let cacheKey = "\(photo.uuid)\(photo.style)\(photo.color)\(Self.identifier)" as NSString

        if let chachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.thumbnailPictureView.image = chachedImage
            return
        }

        let imageSize = CGSize(
            width: bounds.width - 20,
            height: bounds.width - 20
        )

        DispatchQueue.global(qos: .userInteractive).async {
            guard let downsampledCGImage = photo.imageData
                .toDownsampledCGImage(pointSize: imageSize, scale: 2.0) else { return }
            let downsampledUIImage = UIImage(cgImage: downsampledCGImage)

            DispatchQueue.main.async {
                if let image = downsampledUIImage.overlayText(of: photo) {
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                    self.thumbnailPictureView.image = image
                }
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
