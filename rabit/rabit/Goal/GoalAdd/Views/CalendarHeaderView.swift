import UIKit

final class CalendarHeaderView: UICollectionReusableView {
    private let monthLabel: PaddingLabel = {
        let label = PaddingLabel(padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .white
        label.backgroundColor = UIColor(named: "second")
        label.roundCorners()
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

    func configure(with baseDate: Date) {
        monthLabel.text = DateConverter.convertToYearAndMonthString(date: baseDate)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        monthLabel.attributedText = nil
    }
}

private extension CalendarHeaderView {
    func setupViews() {
        addSubview(monthLabel)
        monthLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
