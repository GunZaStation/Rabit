import UIKit
import SnapKit
import RxSwift
import RxGesture

final class GoalAddViewController: UIViewController {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 14
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
        insertField.placeholder = "시작일과 종료일을 선택하세요"
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    private let timeField:InsertField = {
        let insertField = InsertField()
        insertField.title = "인증 시간"
        insertField.placeholder = "문자열 입력"
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
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
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "저장", style: .plain, target: self, action: nil)
        return button
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: GoalAddViewModelProtocol?
    
    convenience init(viewModel: GoalAddViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setAttributes()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)
                
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)
                
        titleField.rx.text
            .bind(to: viewModel.goalTitleInput)
            .disposed(by: disposeBag)
        
        descriptionField.rx.text
            .bind(to: viewModel.goalSubtitleInput)
            .disposed(by: disposeBag)
                
        periodField.rx.tapGesture()
            .when(.recognized)
            .bind { _ in viewModel.periodFieldTouched.accept(()) }
            .disposed(by: disposeBag)
        
        viewModel.selectedPeriod
            .map(\.description)
            .bind(to: periodField.rx.text)
            .disposed(by: disposeBag)
        
        timeField.rx.tapGesture()
            .when(.recognized)
            .bind { _ in viewModel.timeFieldTouched.accept(()) }
            .disposed(by: disposeBag)
        
        viewModel.selectedTime
            .map(\.description)
            .bind(to: timeField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
    }
    
    private func setupViews() {
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.85)
            $0.height.equalToSuperview().multipliedBy(0.5)
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
