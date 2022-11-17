import UIKit
import SnapKit

final class InsertField: UIControl {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(hexRGB: "#1D1D1D")
        return imageView
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexRGB: "#DFDFDF")
        return view
    }()
    
    var icon: String = "" {
        didSet {
            iconImageView.image = UIImage(systemName: icon)
        }
    }
    
    var text: String? {
        didSet {
            textField.text = text
            textField.textColor = .label
            sendActions(for: .valueChanged)
        }
    }
    
    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var isTextFieldEnabled: Bool = true {
        didSet {
            textField.isEnabled = isTextFieldEnabled
        }
    }
    
    var textColor: UIColor? {
        didSet {
            textField.textColor = textColor
        }
    }
    
    var textSize: CGFloat? {
        didSet {
            textField.font = UIFont.systemFont(ofSize: (textSize ?? 10)/750 * UIScreen.main.bounds.height)
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
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
        }
        
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).offset(14)
            $0.height.equalToSuperview().multipliedBy(0.5)
            $0.centerY.equalTo(iconImageView)
        }
        
        addSubview(underLineView)
        underLineView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(13/376 * UIScreen.main.bounds.width)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        text = textField.text
    }
}

extension InsertField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
