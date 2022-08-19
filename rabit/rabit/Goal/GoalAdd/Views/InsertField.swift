import UIKit
import SnapKit

final class InsertField: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.clipsToBounds = true
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 9
        return textField
    }()
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var placeholder: String = "" {
        didSet {
            textField.placeholder = " \(placeholder)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.2)
        }
        
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(10)
            $0.height.centerY.trailing.equalToSuperview()
        }
    }
}
