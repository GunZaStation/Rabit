import UIKit
import SnapKit

final class GoalFormView: UIControl {
    
    weak var delegate: GoalFormViewDelegate?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 14 / 750 * UIScreen.main.bounds.height
        return stackView
    }()
    
    private let titleField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "titleIcon"
        insertField.placeholder = "제목을 입력하세요."
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    private let subtitleField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "subtitleIcon"
        insertField.placeholder = "설명을 입력하세요."
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    private let periodField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "periodIcon"
        insertField.isTextFieldEnabled = false
        insertField.isUserInteractionEnabled = false
        return insertField
    }()
    
    private let timeField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "timeIcon"
        insertField.isTextFieldEnabled = false
        insertField.isUserInteractionEnabled = false
        return insertField
    }()
    
    var title: String = "" {
        didSet {
            titleField.text = title
            sendActions(for: .valueChanged)
        }
    }
    
    var subtitle: String = "" {
        didSet {
            subtitleField.text = title
            sendActions(for: .valueChanged)
        }
    }
    
    var period: String = "" {
        didSet {
            periodField.text = period
            periodField.textColor = UIColor(hexRGB: "#A7A7A7")
            sendActions(for: .valueChanged)
        }
    }
    
    var time: String = "" {
        didSet {
            timeField.text = time
            timeField.textColor = UIColor(hexRGB: "#A7A7A7")
            sendActions(for: .valueChanged)
        }
    }
    
    required convenience init(activate targets: Set<ActivationTarget>) {
        self.init()
        setupViews()
        activateFields(for: targets)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(formTapped(_:))))
    }
    
    @objc private func formTapped(_ gesture: UITapGestureRecognizer) {
        //탭된 부분의 좌표별로 다른 메소드 호출
        let tappedLocation = gesture.location(in: self)
        let tappedX = tappedLocation.x
        let tappedY = tappedLocation.y
        
        if (periodField.frame.minX...periodField.frame.maxX) ~= tappedX &&
            (periodField.frame.minY...periodField.frame.maxY) ~= tappedY {
            (delegate?.periodFiledTouched ?? {})()
            return
        }
        
        if (timeField.frame.minX...timeField.frame.maxX) ~= tappedX &&
            (timeField.frame.minY...timeField.frame.maxY) ~= tappedY {
            (delegate?.timeFieldTouched ?? {})()
            return
        }
    }
    
    func activateFields(for targets:  Set<ActivationTarget>) {
        guard !targets.contains(.nothing) else { return }
        
        for target in targets {
            switch target {
            case .title:
                titleField.isTextFieldEnabled = true
            case .subtitle:
                subtitleField.isTextFieldEnabled = true
            case .period:
                periodField.isUserInteractionEnabled = true
            case .time:
                timeField.isUserInteractionEnabled = true
            default:
                return
            }
        }
    }
        
    private func setupViews() {
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        stackView.addArrangedSubview(titleField)
        stackView.addArrangedSubview(subtitleField)
        stackView.addArrangedSubview(periodField)
        stackView.addArrangedSubview(timeField)
    }
}

extension GoalFormView {
    
    enum ActivationTarget {
        case nothing
        case title
        case subtitle
        case period
        case time
    }
}

@objc protocol GoalFormViewDelegate: AnyObject {
    
    @objc optional func periodFiledTouched()
    @objc optional func timeFieldTouched()
}
