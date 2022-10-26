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
        view.roundCorners(20)
        return view
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " 카테고리 입력"
        textField.leftView = UIView()
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1.0
        textField.roundCorners(10)
        return textField
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t닫기\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.roundCorners(10)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t저장\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.roundCorners(10)
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
            $0.height.equalToSuperview().multipliedBy(0.18)
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
        
        textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.categoryTitleInput)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)
        
        dimmedView.rx.tapGesture()
            .when(.recognized)
            .bind { _ in viewModel.closeButtonTouched.accept(()) }
            .disposed(by: disposeBag)

        viewModel.saveButtonDisabled
            .withUnretained(self)
            .bind(onNext: { viewController, isDisabled in
                viewController.saveButton.backgroundColor = isDisabled ? .lightGray : .systemGreen
                viewController.saveButton.isEnabled = !isDisabled
            })
            .disposed(by: disposeBag)
        
        viewModel.titleInputDuplicated
            .map { !$0 }
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
            $0.height.equalToSuperview().multipliedBy(0.18)
        }
        
        formView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(35)
        }
        
        formView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(35)
        }
        
        formView.addSubview(textField)
        textField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(35)
            $0.height.equalToSuperview().multipliedBy(0.25)
            $0.bottom.equalTo(saveButton.snp.top).offset(-28)
        }
        
        formView.addSubview(warningLabel)
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(35)
        }
    }
}
