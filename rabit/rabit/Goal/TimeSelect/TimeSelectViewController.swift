import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class TimeSelectViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "인증시간 선택"
        label.sizeToFit()
        return label
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.isHidden = true
        return view
    }()
    
    private lazy var timeSelectSheetHeight = view.bounds.height*0.36
    private lazy var timeSelectSheet: BottomSheet = {
        let sheet = BottomSheet(view.bounds.height, timeSelectSheetHeight)
        sheet.backgroundColor = .white
        sheet.roundCorners(20)
        return sheet
    }()
    
    private lazy var timeRangeSliderWidth = view.bounds.width - 40
    private lazy var timeRangeSlider: RangeSlider = {
        let sliderTimeRange: CGFloat = (24 * 60 - 2) / 10 // (24시간 - 2분) / 10분
        let slider = RangeSlider(
            min: 60,
            max: 60*60*23 + 60*59,
            step: timeRangeSliderWidth / sliderTimeRange
        )
        return slider
    }()
    
    private let timePreviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var daySelectCollectionView: UICollectionView = {
        initializeDaySelectCollectionView()
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("\t저장\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundColor(UIColor(named: "third"), for: .normal)
        button.roundCorners(10)
        return button
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: TimeSelectViewModelProtocol?
    
    convenience init(viewModel: TimeSelectViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bind()
        viewModel?.viewDidLoad.accept(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showTimeSelectSheet()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        dimmedView.rx.tapGesture()
            .when(.ended)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hideTimeSelectSheet()
            }
            .disposed(by: disposeBag)
        
        timeSelectSheet.rx.isClosed
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hideTimeSelectSheet()
            }
            .disposed(by: disposeBag)

        timeRangeSlider.rx.leftValue
            .distinctUntilChanged()
            .bind(to: viewModel.selectedStartTime)
            .disposed(by: disposeBag)
        
        timeRangeSlider.rx.rightValue
            .distinctUntilChanged()
            .bind(to: viewModel.selectedEndTime)
            .disposed(by: disposeBag)
        
        viewModel.presetDays
            .bind(to: daySelectCollectionView.rx.items(
                cellIdentifier: DaySelectCell.identifier,
                cellType: DaySelectCell.self
            )) { [weak self] index, day, cell in
                
                cell.configure(with: "\(day)")
                if viewModel.selectedDays.value.contains(day) {
                    self?.daySelectCollectionView.selectItem(
                        at: IndexPath(item: index, section: 0),
                        animated: false,
                        scrollPosition: .init()
                    )
                }
                
                guard #available(iOS 15, *) else {
                    cell.isSelected = true
                    return
                }
            }
            .disposed(by: disposeBag)
        
        daySelectCollectionView.rx.modelSelected(Day.self)
            .withLatestFrom(viewModel.selectedTime) { day, time in
                var days = time.days.selectedValues
                days.insert(day)
                return days
            }
            .bind(to: viewModel.selectedDays)
            .disposed(by: disposeBag)
        
        daySelectCollectionView.rx.modelDeselected(Day.self)
            .withLatestFrom(viewModel.selectedTime) { day, time in
                var days = time.days.selectedValues
                days.remove(day)
                return days
            }
            .bind(to: viewModel.selectedDays)
            .disposed(by: disposeBag)

        viewModel.selectedTime
            .distinctUntilChanged { $0.start == $1.start }
            .take(2)
            .map { Double($0.start.toSeconds()) }
            .bind(to: timeRangeSlider.rx.leftValue)
            .disposed(by: disposeBag)

        viewModel.selectedTime
            .distinctUntilChanged { $0.end == $1.end }
            .take(2)
            .map { Double($0.end.toSeconds()) }
            .bind(to: timeRangeSlider.rx.rightValue)
            .disposed(by: disposeBag)
        
        viewModel.selectedTime
            .map { $0.description }
            .bind(to: timePreviewLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.saveButtonEnabled
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .withUnretained(self) { viewController, _ in
                viewController.hideTimeSelectSheet()
            }
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(timeSelectSheet)
        timeSelectSheet.snp.makeConstraints {
            $0.top.equalToSuperview().offset(view.frame.height)
            $0.height.equalTo(timeSelectSheetHeight)
            $0.leading.trailing.equalToSuperview()
            
        }
        
        timeSelectSheet.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(20)
        }

        timeSelectSheet.contentView.addSubview(daySelectCollectionView)
        daySelectCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.17)
        }

        timeSelectSheet.contentView.addSubview(timePreviewLabel)
        timePreviewLabel.snp.makeConstraints {
            $0.top.equalTo(daySelectCollectionView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        timeSelectSheet.contentView.addSubview(timeRangeSlider)
        timeRangeSlider.snp.makeConstraints {
            $0.top.equalTo(timePreviewLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(timeRangeSliderWidth)
            $0.height.equalToSuperview().multipliedBy(0.08)
        }
        
        timeSelectSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.top.equalTo(timeRangeSlider.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
    }
}

private extension TimeSelectViewController {
    
    func initializeDaySelectCollectionView() -> UICollectionView {
        
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
            DaySelectCell.self,
            forCellWithReuseIdentifier: DaySelectCell.identifier
        )
        
        return collectionView
    }
    
    func showTimeSelectSheet() {
        
        dimmedView.isHidden = false
        
        timeSelectSheet.move(
            upTo: view.bounds.height - timeSelectSheetHeight,
            duration: 0.2,
            animation: self.view.layoutIfNeeded
        )
    }
    
    func hideTimeSelectSheet() {
        guard let viewModel = viewModel else { return }
    
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
