import UIKit
import RxSwift
import RxCocoa

final class TimeSelectViewController: UIViewController {
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.isHidden = true
        return view
    }()
    
    private let timeSelectSheet: BottomSheet = {
        let sheet = BottomSheet()
        sheet.backgroundColor = .white
        sheet.roundCorners(20)
        return sheet
    }()
    
    private let timeRangleSlider: RangeSlider = {
        let slider = RangeSlider(min: 60, max: 60*60*23 + 60*59)
        return slider
    }()
    
    private let timePreviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("\t저장\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.roundCorners(10)
        return button
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: TimeSelectViewModel?
    
    convenience init(viewModel: TimeSelectViewModel) {
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
        
        showPeriodSheet()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
                
        dimmedView.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)
        
        timeSelectSheet.rx.swipeGesture(.down)
            .when(.ended)
            .withUnretained(self)
            .bind { viewController, temp in
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)
       
        timeRangleSlider.rx.leftValue
            .bind(to: viewModel.selectedStartTime)
            .disposed(by: disposeBag)
        
        timeRangleSlider.rx.rightValue
            .bind(to: viewModel.selectedEndTime)
            .disposed(by: disposeBag)

        viewModel.selectedTime
            .map { $0.description }
            .bind(to: timePreviewLabel.rx.text)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withUnretained(self)
            .bind(onNext: { viewController, _ in
                viewModel.saveButtonTouched.accept(())
                viewController.hidePeriodSheet()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(timeSelectSheet)
        timeSelectSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.snp.bottom)
        }
        
        timeSelectSheet.contentView.addSubview(timePreviewLabel)
        timePreviewLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        timeSelectSheet.contentView.addSubview(timeRangleSlider)
        timeRangleSlider.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalToSuperview().multipliedBy(0.7)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        timeSelectSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
    }
}

private extension TimeSelectViewController {
    
    func showPeriodSheet() {
        
        dimmedView.isHidden = false
        isModalInPresentation = true
        
        timeSelectSheet.move(
            upTo: view.bounds.height*0.45,
            duration: 0.2,
            animation: self.view.layoutIfNeeded
        )
    }
    
    func hidePeriodSheet() {
        guard let viewModel = viewModel else { return }
        
        isModalInPresentation = false
        
        timeSelectSheet.move(
            upTo: view.bounds.height,
            duration: 0.2,
            animation: view.layoutIfNeeded
        ) { _ in
            self.dimmedView.isHidden = true
            viewModel.closingViewRequested.accept(())
        }
    }
}
