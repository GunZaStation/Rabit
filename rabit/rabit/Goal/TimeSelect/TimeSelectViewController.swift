import UIKit
import RxSwift
import RxCocoa

final class TimeSelectViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "인증시간 선택"
        return label
    }()
    
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
    
    private let timeRangeSlider: RangeSlider = {
        let slider = RangeSlider(min: 60, max: 60*60*23 + 60*59)
        return slider
    }()
    
    private let timePreviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var weekdayCollectionView: UICollectionView = {
        initializeWeekdaySelectCollectionView()
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
            .bind { viewController, _ in
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)
        
        timeRangeSlider.rx.leftValue
            .bind(to: viewModel.selectedStartTime)
            .disposed(by: disposeBag)
        
        timeRangeSlider.rx.rightValue
            .bind(to: viewModel.selectedEndTime)
            .disposed(by: disposeBag)
        
        viewModel.weekdayNames
            .bind(to: weekdayCollectionView.rx.items(
                cellIdentifier: WeekdaySelectCell.identifier,
                cellType: WeekdaySelectCell.self
            )) {_, weekdayName, cell in
                cell.configure(with: weekdayName)
            }
            .disposed(by: disposeBag)
        
        viewModel.selectedTime
            .map { $0.description }
            .bind(to: timePreviewLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.selectedTime
            .map { Double($0.start.toSeconds()) }
            .bind(to: timeRangeSlider.rx.leftValue)
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
        
        timeSelectSheet.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
        }

        timeSelectSheet.contentView.addSubview(weekdayCollectionView)
        weekdayCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.2)
        }

        timeSelectSheet.contentView.addSubview(timePreviewLabel)
        timePreviewLabel.snp.makeConstraints {
            $0.top.equalTo(weekdayCollectionView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        timeSelectSheet.contentView.addSubview(timeRangeSlider)
        timeRangeSlider.snp.makeConstraints {
            $0.top.equalTo(timePreviewLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.1)
        }
        
        timeSelectSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
    }
}

private extension TimeSelectViewController {
    
    func initializeWeekdaySelectCollectionView() -> UICollectionView {
        
        let layout = CompositionalLayoutFactory.shared.create(
            widthFraction: 1/7,
            heightFraction: 1.0
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(
            WeekdaySelectCell.self,
            forCellWithReuseIdentifier: WeekdaySelectCell.identifier
        )
        
        return collectionView
    }
    
    func showPeriodSheet() {
        
        dimmedView.isHidden = false
        isModalInPresentation = true
        
        timeSelectSheet.move(
            upTo: view.bounds.height*0.65,
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
