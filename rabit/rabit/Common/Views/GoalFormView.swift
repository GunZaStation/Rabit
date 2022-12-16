import UIKit
import SnapKit

final class GoalFormView: UIControl {
    
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
    
    private let descriptionField: InsertField = {
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
    
    var goalDescription: String = "" {
        didSet {
            descriptionField.text = title
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
    }
    
    func activateFields(for targets:  Set<ActivationTarget>) {
        guard !targets.contains(.nothing) else { return }
        
        for target in targets {
            switch target {
            case .title:
                titleField.isTextFieldEnabled = true
            case .description:
                descriptionField.isTextFieldEnabled = true
            case .period:
                periodField.isUserInteractionEnabled = true
            case .time:
                titleField.isUserInteractionEnabled = true            default:
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
        stackView.addArrangedSubview(descriptionField)
        stackView.addArrangedSubview(periodField)
        stackView.addArrangedSubview(timeField)
    }
}

extension GoalFormView {
    
    enum ActivationTarget {
        case nothing
        case title
        case description
        case period
        case time
    }
}
