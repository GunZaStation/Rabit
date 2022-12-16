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
    
    let titleField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "titleIcon"
        insertField.placeholder = "제목을 입력하세요."
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    let descriptionField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "subtitleIcon"
        insertField.placeholder = "설명을 입력하세요."
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    let periodField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "periodIcon"
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    let timeField: InsertField = {
        let insertField = InsertField()
        insertField.textSize = 15
        insertField.icon = "timeIcon"
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    convenience init(activate targets: [ActivationTarget]) {
        self.init()
        setupViews()
        activateFields(targets: targets)
    }
    
    private func activateFields(targets: [ActivationTarget]) {
        
        for target in targets {
            switch target {
            case .title:
                titleField.isTextFieldEnabled = true
            case .description:
                descriptionField.isTextFieldEnabled = true
            case .period:
                periodField.isTextFieldEnabled = true
            case .time:
                timeField.isTextFieldEnabled = true
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
        case title
        case description
        case period
        case time
    }
}
