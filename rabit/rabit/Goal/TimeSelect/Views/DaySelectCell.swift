import UIKit
import SnapKit

final class DaySelectCell: UICollectionViewCell {
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.roundCorners(self.bounds.height/2)
        return label
    }()

    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemBlue
        imageView.isHidden = true
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            checkMarkImageView.isHidden = !isSelected
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.roundCorners(self.bounds.height/2)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
     
    func configure(with weekdayName: String) {
        nameLabel.text = weekdayName
    }
}

private extension DaySelectCell {
    func setupViews() {
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addSubview(checkMarkImageView)
        checkMarkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

