import UIKit
import SnapKit

final class GoalListCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textColor = .black
        label.text = "title"
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.text = "subtitle"
        return label
    }()
    
    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 5/750 * UIScreen.main.bounds.height
        return stackView
    }()
    
    private let goalProgressView: CircularProgressBar = {
        let progressView = CircularProgressBar()
        progressView.backgroundColor = .clear
        return progressView
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAttributes()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(goal: Goal) {

        titleLabel.text = goal.title
        subTitleLabel.text = goal.subtitle
        
        guard goal.target != 0 else { return }
        let ratio = CGFloat(goal.progress) /  CGFloat(goal.target)
        goalProgressView.progress = ratio
    }
            
    private func setAttributes() {
        
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor(hexRGB: "#D9D9D9")?.cgColor
        contentView.roundCorners(10)
    }
    
    private func setupViews() {
        
        contentView.addSubview(goalProgressView)
        goalProgressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20/376 * UIScreen.main.bounds.width)
            make.centerY.equalToSuperview()
            make.width.equalTo(45/336 * UIScreen.main.bounds.width)
            make.height.equalTo(goalProgressView.snp.width)
        }
        
        contentView.addSubview(titleStackView)
        titleStackView.snp.makeConstraints { make in
            make.leading.equalTo(goalProgressView.snp.trailing).offset(20/376 * UIScreen.main.bounds.width)
            make.trailing.equalToSuperview().inset(20/376 * UIScreen.main.bounds.width)
            make.top.equalToSuperview().offset(24/750 * UIScreen.main.bounds.height)
            make.centerY.equalToSuperview()
        }
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        
        contentView.addSubview(menuButton)
        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(titleStackView.snp.top)
            make.trailing.equalToSuperview().inset(20/376 * UIScreen.main.bounds.width)
        }
    }
}
