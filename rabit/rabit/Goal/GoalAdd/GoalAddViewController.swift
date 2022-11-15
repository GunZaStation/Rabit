import UIKit
import SnapKit
import RxSwift
import RxGesture

final class GoalAddViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .init(rawValue: 700))
        label.text = "습관 추가"
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 14
        return stackView
    }()
    
    private let titleField: InsertField = {
        let insertField = InsertField()
        insertField.icon = "line.3.horizontal"
        insertField.placeholder = "제목을 입력하세요."
        return insertField
    }()
    
    private let descriptionField: InsertField = {
        let insertField = InsertField()
        insertField.icon = "doc.text.magnifyingglass"
        insertField.placeholder = "설명을 입력하세요."
        return insertField
    }()
    
    private let periodField: InsertField = {
        let insertField = InsertField()
        insertField.icon = "calendar.circle"
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    private let timeField: InsertField = {
        let insertField = InsertField()
        insertField.icon = "alarm"
        insertField.isTextFieldEnabled = false
        return insertField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        button.isEnabled = false
        button.setBackgroundColor(UIColor(hexRGB: "#F16B22"), for: .normal)
        button.setBackgroundColor(.lightGray, for: .disabled)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveButton.roundCorners(saveButton.frame.height/2)
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        saveButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)
                
        navigationItem.leftBarButtonItem?.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)
                
        titleField.rx.text
            .bind(to: viewModel.goalTitleInput)
            .disposed(by: disposeBag)
        
        viewModel.saveButtonDisabled
            .map { !$0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        descriptionField.rx.text
            .bind(to: viewModel.goalSubtitleInput)
            .disposed(by: disposeBag)
                
        periodField.rx.tapGesture()
            .when(.ended)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind { _ in viewModel.periodFieldTouched.accept(()) }
            .disposed(by: disposeBag)
        
        viewModel.selectedPeriod
            .map(\.description)
            .bind(to: periodField.rx.text)
            .disposed(by: disposeBag)

        Observable.just("목표 기간을 설정하세요.")
            .withUnretained(self)
            .bind { viewController, text in
                viewController.periodField.text = text
                viewController.periodField.textColor = UIColor(hexRGB: "#A7A7A7")
            }
            .disposed(by: disposeBag)
        
        timeField.rx.tapGesture()
            .when(.ended)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind { _ in viewModel.timeFieldTouched.accept(()) }
            .disposed(by: disposeBag)
        
        viewModel.selectedTime
            .map(\.description)
            .bind(to: timeField.rx.text)
            .disposed(by: disposeBag)
        
        Observable.just("인증 시간을 입력하세요.")
            .withUnretained(self)
            .bind { viewController, text in
                viewController.timeField.text = text
                viewController.timeField.textColor = UIColor(hexRGB: "#A7A7A7")
            }
            .disposed(by: disposeBag)
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
    }
    
    private func setupViews() {
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(48)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.85)
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        
        stackView.addArrangedSubview(titleField)
        stackView.addArrangedSubview(descriptionField)
        stackView.addArrangedSubview(periodField)
        stackView.addArrangedSubview(timeField)
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(40)
            make.height.equalToSuperview().multipliedBy(0.07)
        }
    }
}
