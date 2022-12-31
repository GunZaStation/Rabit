import UIKit
import SnapKit
import RxSwift
import RxGesture

final class GoalDetailViewController: UIViewController {
    
    private let formView = GoalFormView(activate: [.nothing])
    
    private lazy var certView: DottedLineView = {
        let view = DottedLineView()
        return view
    }()
    
    private lazy var editingBarItem = UIBarButtonItem(title: "수정하기", style: .plain, target: self, action: nil)
    
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
        
        guard let viewModel = viewModel else { return }
        bind(from: viewModel)
        bind(to: viewModel)
    }
    
    private func bind(from viewModel: GoalDetailViewModelOutput) {
        
        viewModel.goalTitleOutput
            .bind(to: formView.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.goalSubtitleOutput
            .bind(to: formView.rx.subtitle)
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
    
    private func bind(to viewModel: GoalDetailViewModelInput) {
        
        navigationItem.leftBarButtonItem?.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(to: viewModel.closeButtonTouched)
            .disposed(by: disposeBag)
        
        formView.rx.title
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(to: viewModel.goalTitleInput)
            .disposed(by: disposeBag)

        formView.rx.subtitle
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(to: viewModel.goalSubtitleInput)
            .disposed(by: disposeBag)
        
        editingBarItem.rx.tap
            .scan(false) { lastState, newState in !lastState }
            .map { $0 }
            .withUnretained(self)
            .bind(onNext: { (viewController, enableEditing) in
                if enableEditing {
                    viewController.editingBarItem.title = "저장하기"
                    viewController.formView.activateFields(for: [.title, .subtitle])
                    viewController.formView.becomeFirstResponder()
                } else {
                    viewController.editingBarItem.title = "수정하기"
                    viewController.formView.activateFields(for: [.nothing])
                    viewModel.saveButtonTouched.accept(())
                }
            })
            .disposed(by: disposeBag)
                
        certView.rx.tapGesture()
            .when(.ended)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .bind(onNext: { _ in
                viewModel.showCertPhotoCameraView.accept(())
            })
            .disposed(by: disposeBag)
    }
        
    private func setAttributes() {
        
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = editingBarItem
    }
    
    private func setupViews() {
        
        view.addSubview(formView)
        formView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10/750 * UIScreen.main.bounds.height)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        
        view.addSubview(certView)
        certView.snp.makeConstraints { make in
            make.top.equalTo(formView.snp.bottom).offset(10/750 * UIScreen.main.bounds.height)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.85)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10/750 * UIScreen.main.bounds.height)
        }
    }
}
