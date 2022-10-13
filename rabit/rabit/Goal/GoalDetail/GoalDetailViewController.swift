import UIKit
import SnapKit
import RxSwift

final class GoalDetailViewController: UIViewController {
    
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
        insertField.isUserInteractionEnabled = false
        return insertField
    }()
    
    private let timeField:InsertField = {
        let insertField = InsertField()
        insertField.title = "인증 시간"
        insertField.placeholder = "문자열 입력"
        insertField.isUserInteractionEnabled = false
        return insertField
    }()
    
    private lazy var certView: DottedLineView = {
        let view = DottedLineView()
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: GoalDetailViewModel?
    
    convenience init(viewModel: GoalDetailViewModel) {
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
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)
                
        titleField.rx.text
            .bind(to: viewModel.goalTitleInput)
            .disposed(by: disposeBag)
        
        descriptionField.rx.text
            .bind(to: viewModel.goalSubtitleInput)
            .disposed(by: disposeBag)
        
        viewModel.goalTitleOutput
            .bind(to: titleField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.goalSubtitleOutput
            .bind(to: descriptionField.rx.text)
            .disposed(by: disposeBag)
    
        viewModel.selectedPeriod
            .map(\.description)
            .bind(to: periodField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.selectedTime
            .map(\.description)
            .bind(to: timeField.rx.text)
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)
        
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .systemBackground
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
        
        view.addSubview(certView)
        certView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.85)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
        }
    }
}
