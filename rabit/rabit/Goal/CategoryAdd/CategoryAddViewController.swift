import UIKit
import SnapKit
import RxCocoa
import RxGesture
import RxSwift

final class CategoryAddViewController: UIViewController {
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        return view
    }()
    
    private let formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.roundCorners(15)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리 생성"
        label.font = UIFont.systemFont(ofSize: 20, weight: .init(rawValue: 700))
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "카테고리를 입력하세요."
        textField.leftView = UIView()
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1.0
        textField.roundCorners(10)
        textField.addLeftPadding(width: 20)
        return textField
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("취소", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor(hexRGB: "#676767"), for: .normal)
        button.backgroundColor = UIColor(hexRGB: "#F2F2F2")
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hexRGB: "#DFDFDF")?.cgColor
        button.roundCorners(20)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("저장", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundColor(UIColor(hexRGB: "#F16B22"), for: .normal)
        button.setBackgroundColor(.lightGray, for: .disabled)
        button.roundCorners(20)
        button.isEnabled = false
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "이미 존재하는 카테고리 입니다."
        label.textColor = .red
        label.font = .systemFont(ofSize: 15)
        label.isHidden = true
        return label
    }()
    
    private var viewModel: CategoryAddViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: CategoryAddViewModelProtocol) {

        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showFormView()
    }
    
    private func showFormView() {
        
        formView.snp.remakeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalToSuperview().multipliedBy(0.28)
        }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            animations: self.view.layoutIfNeeded,
            completion: nil
        )        
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
      
        textField.rx
            .controlEvent([.editingChanged])
            .withLatestFrom(textField.rx.text)
            .compactMap { $0 }
            .bind(to: viewModel.categoryTitleInput)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)
        
        dimmedView.rx.tapGesture()
            .when(.ended)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind { _ in viewModel.closeButtonTouched.accept(()) }
            .disposed(by: disposeBag)

        viewModel.saveButtonDisabled
            .map { !$0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.warningLabelHidden
            .bind(to: warningLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        view.addSubview(formView)
        formView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.height.equalToSuperview().multipliedBy(0.28)
        }
        
        formView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(43)
            $0.centerX.equalToSuperview()
        }
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        formView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(35)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(122)
            $0.height.equalTo(44)
        }
        
        formView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(35)
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(saveButton)
        }
        
        formView.addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(25)
            $0.height.equalToSuperview().multipliedBy(0.20)
        }
        
        formView.addSubview(warningLabel)
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(35)
        }
    }
}
