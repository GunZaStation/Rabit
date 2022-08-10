import UIKit
import SnapKit

final class GoalListCollectionViewHeader: UICollectionReusableView {
    
    static var identifier: String { .init(describing: self) }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
        
    private func setupViews() {
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
            $0.trailing.equalToSuperview().inset(10)
        }
    }
}
