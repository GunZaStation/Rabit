import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class CategoryAddViewController: UIViewController {
    
    private let formView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " 카테고리 입력"
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.cornerRadius = 5
        textField.clipsToBounds = true
        textField.layer.borderWidth = 1.0
        return textField
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t닫기\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemOrange
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("\t저장\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemGreen
        
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var viewModel: CategoryAddViewModel?
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: CategoryAddViewModel) {

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
        
        textField.rx.text
            .compactMap { $0 }
            .bind(to: viewModel.input.categoryTitle)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(to: viewModel.input.closeButtonTouched)
            .disposed(by: disposeBag)
        
        viewModel.input.closeButtonTouched
            .withUnretained(self)
            .bind(onNext: { viewController, _ in
                viewController.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(formView)
        formView.snp.makeConstraints {
            $0.center.equalToSuperview()
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
            $0.leading.equalToSuperview().offset(35)
            $0.trailing.equalToSuperview().inset(35)
            $0.height.equalToSuperview().multipliedBy(0.25)
            $0.bottom.equalTo(saveButton.snp.top).offset(-22)
        }
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .black.withAlphaComponent(0.6)
    }
}
