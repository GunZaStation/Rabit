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
        label.textColor = .systemGray
        label.text = "subtitle"
        return label
    }()
    
    private let goalProgressView: GoalProgressView = {
        let view = GoalProgressView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
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
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.roundCorners(10)
    }
    
    private func setupViews() {
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(20)
        }

        contentView.addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
        }

        contentView.addSubview(goalProgressView)
        goalProgressView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(30)
        }
    }
}
