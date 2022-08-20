import UIKit
import SnapKit
import RxSwift

final class GoalAddViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12.5
        return stackView
    }()
    
    private let titleField: InsertField = {
        let insertField = InsertField()
        insertField.title = "제목"
        insertField.placeholder = "문자열 입력"
        return insertField
    }()
    
    private let descriptionField:InsertField = {
        let insertField = InsertField()
        insertField.title = "설명"
        insertField.placeholder = "문자열 입력"
        return insertField
    }()
    
    private let periodField:InsertField = {
        let insertField = InsertField()
        insertField.title = "목표 기간"
        insertField.placeholder = "문자열 입력"
        return insertField
    }()
    
    private let timeField:InsertField = {
        let insertField = InsertField()
        insertField.title = "인증 시간"
        insertField.placeholder = "문자열 입력"
        return insertField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("저장하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return button
    }()
    
    private lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
        return button
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: GoalAddViewModel?
    
    convenience init(viewModel: GoalAddViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setAttributes()
        bind()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }

        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = "새로운 목표 만들기"
    }
    
    private func setupViews() {
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.3)
        }
                
        stackView.addArrangedSubview(titleField)
        stackView.addArrangedSubview(descriptionField)
        stackView.addArrangedSubview(periodField)
        stackView.addArrangedSubview(timeField)
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.11)
        }
    }
}
