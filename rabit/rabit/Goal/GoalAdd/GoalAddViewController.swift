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
    
    private let formView = GoalFormView(activate: [.title, .subtitle, .period, .time])
    
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
                
        formView.rx.title
            .compactMap { $0 }
            .bind(to: viewModel.goalTitleInput)
            .disposed(by: disposeBag)
        
        viewModel.saveButtonDisabled
            .map { !$0 }
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        formView.rx.subtitle
            .compactMap { $0 } 
            .bind(to: viewModel.goalSubtitleInput)
            .disposed(by: disposeBag)
        
        formView.rx.periodFieldTouched
            .bind(to: viewModel.periodFieldTouched)
            .disposed(by: disposeBag)
        
        formView.rx.timeFieldTouched
            .bind(to: viewModel.timeFieldTouched)
            .disposed(by: disposeBag)
                    
        viewModel.selectedPeriod
            .map(\.description)
            .bind(to: formView.rx.period)
            .disposed(by: disposeBag)

        viewModel.selectedTime
            .map(\.description)
            .bind(to: formView.rx.time)
            .disposed(by: disposeBag)
    }
    
    private func setAttributes() {
        
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: nil)
    }
    
    private func setupViews() {
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(48/750 * UIScreen.main.bounds.height)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(formView)
        formView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40/750 * UIScreen.main.bounds.height)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalToSuperview().multipliedBy(0.5)
        }

        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30/376 * UIScreen.main.bounds.width)
            make.trailing.equalToSuperview().inset(30/376 * UIScreen.main.bounds.width)
            make.bottom.equalToSuperview().inset(40/750 * UIScreen.main.bounds.height)
            make.height.equalToSuperview().multipliedBy(0.07)
        }
    }
}
