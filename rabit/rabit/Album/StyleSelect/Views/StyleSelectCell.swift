import UIKit
import SnapKit

final class StyleSelectCell: UICollectionViewCell {
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.35)
        view.isHidden = true
        return view
    }()

    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .gray
        imageView.isHidden = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()

    override var isSelected: Bool {
        didSet {
            if isSelected {
                dimmedView.isHidden = false
                checkMarkImageView.isHidden = false
            } else {
                dimmedView.isHidden = true
                checkMarkImageView.isHidden = true
            }
        }
    }

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
            width: bounds.width,
            height: bounds.width
        )

            let image = photo.imageData.toDownsampledImage(pointSize: imageSize, scale: 2.0)
        DispatchQueue.global().async {

            DispatchQueue.main.async {
                self.previewImageView.image = image?.overlayText(of: photo)
                self.nameLabel.text = photo.style.rawValue
            }
        }
    }
}

private extension StyleSelectCell {
    func setupViews() {
        addSubview(previewImageView)
        previewImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(previewImageView.snp.width)
        }

        addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalTo(previewImageView)
        }

        addSubview(checkMarkImageView)
        checkMarkImageView.snp.makeConstraints { make in
            make.center.equalTo(previewImageView)
        }

        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(previewImageView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
