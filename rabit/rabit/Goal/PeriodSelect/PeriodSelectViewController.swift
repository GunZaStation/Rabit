import UIKit
import SnapKit
import RxSwift
import RxDataSources

final class PeriodSelectViewController: UIViewController {
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.isHidden = true
        return view
    }()
    
    private let periodSheet: BottomSheet = {
        let sheet = BottomSheet()
        sheet.backgroundColor = .white
        sheet.roundCorners(20)
        return sheet
    }()
    
    private let calendarView = CalendarView()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("\t저장\t", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.roundCorners(10)
        button.setBackgroundColor(UIColor(named: "third"), for: .normal)
        button.setBackgroundColor(.systemGray3, for: .disabled)
        return button
    }()
    
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<CalendarDates> = {
        initializeDataSource()
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: PeriodSelectViewModelProtocol?

    convenience init(viewModel: PeriodSelectViewModelProtocol) {
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
        
        periodSheet.rx.swipeGesture(.down)
            .when(.recognized)
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)
        
        viewModel.calendarData
            .bind(to: calendarView.calendarCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .withUnretained(self)
            .bind(onNext: { viewController, _ in
                viewModel.saveButtonTouched.accept(())
                viewController.hidePeriodSheet()
            })
            .disposed(by: disposeBag)

        viewModel.saveButtonState
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        calendarView.bind(to: viewModel)
    }
    
    private func setupViews() {
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(periodSheet)
        periodSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.snp.bottom)
        }
        
        periodSheet.contentView.addSubview(calendarView)
        calendarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
        }
        
        periodSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
        }
    }
}

private extension PeriodSelectViewController {
    
    func showPeriodSheet() {
        
        dimmedView.isHidden = false
        isModalInPresentation = true

        periodSheet.move(
            upTo: view.bounds.height*0.48,
            duration: 0.2,
            animation: self.view.layoutIfNeeded
        )
    }
    
    func hidePeriodSheet() {
        guard let viewModel = viewModel else { return }
        
        isModalInPresentation = false
        
        periodSheet.move(
            upTo: view.bounds.height,
            duration: 0.2,
            animation: view.layoutIfNeeded
        ) { _ in
            self.dimmedView.isHidden = true
            viewModel.closingViewRequested.accept(())
        }
    }

    func initializeDataSource() -> RxCollectionViewSectionedReloadDataSource<CalendarDates> {
        return RxCollectionViewSectionedReloadDataSource<CalendarDates>(
            configureCell: self.configureCell
        )
    }

    func configureCell(
        _ dataSource: CollectionViewSectionedDataSource<CalendarDates>,
        _ collectionView: UICollectionView,
        _ indexPath: IndexPath,
        _ item: CalendarDates.Item
    ) -> UICollectionViewCell {
        guard let periodData = viewModel?.selectedPeriod.value,
              let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCell.identifier,
                for: indexPath
              ) as? CalendarCell else { return UICollectionViewCell() }

        let isStartDate = item.date.isSameDate(with: periodData.start)
        let isEndDate = item.date.isSameDate(with: periodData.end)

        if isStartDate || isEndDate {
            collectionView.selectItem(
                at: indexPath,
                animated: false,
                scrollPosition: .init()
            )
        }

        cell.configure(with: item)
        return cell
    }
}
