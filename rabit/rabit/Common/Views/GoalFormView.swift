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
    
    private lazy var titleField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "titleIcon"
        insertField.placeholder = "제목을 입력하세요."
        insertField.isTextFieldEnabled = false
        insertField.addTarget(self, action: #selector(titleFieldDidChange(_:)), for: .editingChanged)
        return insertField
    }()
    
    private lazy var subtitleField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "subtitleIcon"
        insertField.placeholder = "설명을 입력하세요."
        insertField.isTextFieldEnabled = false
        insertField.addTarget(self, action: #selector(subtitleFieldDidChange(_:)), for: .editingChanged)
        return insertField
    }()
    
    private let periodField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "periodIcon"
        insertField.placeholder = "목표 기간을 설정하세요"
        insertField.isTextFieldEnabled = false
        insertField.isUserInteractionEnabled = false
        return insertField
    }()
    
    private let timeField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "timeIcon"
        insertField.placeholder = "인증 시간을 입력하세요."
        insertField.isTextFieldEnabled = false
        insertField.isUserInteractionEnabled = false
        return insertField
    }()
    
    var title: String? {
        didSet {
            titleField.text = title ?? ""
            sendActions(for: .valueChanged)
        }
    }
    
    var subtitle: String? {
        didSet {
            subtitleField.text = subtitle ?? ""
            sendActions(for: .valueChanged)
        }
    }
    
    var period: String = "" {
        didSet {
            periodField.text = period
            sendActions(for: .valueChanged)
        }
    }
    
    var time: String = "" {
        didSet {
            timeField.text = time
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
    
    func activateFields(for targets: Set<ActivationTarget>) {
        
        var insertFieldMap: [ActivationTarget: InsertField] = [
            ActivationTarget.title: titleField,
            ActivationTarget.subtitle: subtitleField,
            ActivationTarget.period: periodField,
            ActivationTarget.time: timeField
        ]
        
        guard !targets.contains(.nothing) else {
            insertFieldMap.values.forEach { ActivationTarget.nothing.activate($0) }
            return
        }
        
        targets.forEach { $0.activate(insertFieldMap[$0]) }
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
    
    @objc private func titleFieldDidChange(_ insertField: InsertField) {
        title = insertField.text
    }
    
    @objc private func subtitleFieldDidChange(_ insertField: InsertField) {
        subtitle = insertField.text
    }
}

extension GoalFormView {
    
    enum ActivationTarget {
        case nothing
        case title
        case subtitle
        case period
        case time
        
        func activate(_ insertField: InsertField?) {
            guard let insertField = insertField else { return }
            
            switch self {
            case .title, .subtitle:
                insertField.isTextFieldEnabled = true
            case .period, .time:
                insertField.isUserInteractionEnabled = true
            case .nothing:
                insertField.isTextFieldEnabled = false
                insertField.isUserInteractionEnabled = false
            }
        }
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return titleField.becomeFirstResponder()
    }
}

@objc protocol GoalFormViewDelegate: AnyObject {
    
    @objc optional func periodFiledTouched()
    @objc optional func timeFieldTouched()
}
