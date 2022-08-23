import UIKit
import SnapKit

final class PresetColorCell: UICollectionViewCell {
    private let presetColorView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 2.5
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        return view
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

    func configure(with hexColorString: String) {
        presetColorView.backgroundColor = UIColor(hexRGB: hexColorString)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        dimmedView.isHidden = true
        checkMarkImageView.isHidden = true
    }
}

private extension PresetColorCell {
    func setupViews() {
        addSubview(presetColorView)
        addSubview(dimmedView)
        addSubview(checkMarkImageView)

        presetColorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        checkMarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
