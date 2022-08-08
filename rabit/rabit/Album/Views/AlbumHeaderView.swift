import UIKit
import SnapKit

final class AlbumHeaderView: UICollectionReusableView {
    static let identifier = String(describing: AlbumHeaderView.self)

    private let dateLabel: PaddingLabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.clipsToBounds = true
        label.layer.cornerCurve = .continuous
        label.layer.cornerRadius = 10
        label.backgroundColor = .blue
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    func configure(with text: String?) {
        dateLabel.text = text
    }
}

private extension AlbumHeaderView {
    // MARK: - Setup UI
    func setupViews() {
        addSubview(dateLabel)

        dateLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(self)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).inset(10)
        }
    }
}
