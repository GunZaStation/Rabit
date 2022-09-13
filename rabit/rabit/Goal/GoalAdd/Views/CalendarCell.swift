import UIKit

final class CalendarCell: UICollectionViewCell {
    private let indicatingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "second")
        view.isHidden = true
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
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

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.attributedText = nil
        dateLabel.text = nil
        indicatingView.isHidden = true
    }

    func configure(with day: CalendarDate) {
        if day.isBeforeToday {
            dateLabel.attributedText = day.number.strikeThrough()
        } else {
            dateLabel.text = day.number
        }

        updateSelectionStatus(of: day)
        isHidden = !day.isWithinDisplayedMonth
    }
}

private extension CalendarCell {
    func setupViews() {
        let size = traitCollection.horizontalSizeClass == .compact ? min(min(frame.width, frame.height) - 10, 60) : 45

        contentView.addSubview(indicatingView)
        indicatingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(indicatingView.snp.width)
        }

        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        indicatingView.roundCorners(size/2)
    }

    func updateSelectionStatus(of day: CalendarDate) {
        if day.isSelected {
            applySelectedStyle()
        } else {
            applyDefaultStyle(isBeforeToday: day.isBeforeToday)
        }
    }

    func applySelectedStyle() {
        dateLabel.textColor = .white
        indicatingView.isHidden = false
    }

    func applyDefaultStyle(isBeforeToday: Bool) {
        dateLabel.textColor = isBeforeToday ? .systemGray4 : .label
        indicatingView.isHidden = true
    }
}
