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
    
    private lazy var periodSelectSheetHeight = view.bounds.height * 0.5
    private lazy var periodSelectSheet: BottomSheet = {
        let sheet = BottomSheet(view.bounds.height, periodSelectSheetHeight)
        sheet.backgroundColor = .white
        sheet.roundCorners(20)
        return sheet
    }()
    
    private let calendarCollectionView: UICollectionView = {
        let screenSize = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenSize.width/10, height: screenSize.width/10)
        layout.headerReferenceSize = CGSize(width: screenSize.width, height: 35)
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        return collectionView
    }()
    
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
        setupCalendarCollectionViewAttributes()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showPeriodSheet()
    }
    
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        dimmedView.rx.tapGesture()
            .when(.ended)
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)
        
        periodSheet.rx.isClosed
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)
        
        viewModel.calendarData
            .bind(to: calendarCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .withUnretained(self)
            .bind { viewController, _ in
                viewModel.saveButtonTouched.accept(())
                viewController.hidePeriodSheet()
            }
            .disposed(by: disposeBag)

        viewModel.saveButtonState
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)

        calendarCollectionView.rx.itemSelected
            .withLatestFrom(
                calendarCollectionView.rx.modelSelected(CalendarDates.Item.self),
                resultSelector: { ($0, $1) }
            )
            .withUnretained(self.calendarCollectionView) { ($0, $1.0, $1.1) }
            .bind { collectionView, indexPath, selectedItemData in
                if let selectedItemsIndexPaths = collectionView.indexPathsForSelectedItems,
                   selectedItemsIndexPaths.count > 2 {
                    selectedItemsIndexPaths
                        .filter { $0 != indexPath }
                        .map { ($0, false) }
                        .forEach(collectionView.deselectItem(at:animated:))
                }

                viewModel.selectedDate.accept(selectedItemData)
            }
            .disposed(by: disposeBag)

        calendarCollectionView.rx.modelDeselected(CalendarDates.Item.self)
            .bind(to: viewModel.deselectedDate)
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        view.addSubview(periodSelectSheet)
        periodSelectSheet.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.bounds.height)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(periodSelectSheetHeight)
        }
        
        periodSelectSheet.contentView.addSubview(calendarCollectionView)
        calendarCollectionView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalToSuperview().multipliedBy(0.75)
        }
        
        periodSelectSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(calendarCollectionView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
}

private extension PeriodSelectViewController {

    func setupCalendarCollectionViewAttributes() {
        calendarCollectionView.register(
            CalendarCell.self,
            forCellWithReuseIdentifier: CalendarCell.identifier
        )

        calendarCollectionView.register(
            CalendarHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CalendarHeaderView.identifier
        )
    }
    
    func showPeriodSheet() {
        
        dimmedView.isHidden = false

        periodSelectSheet.move(
            upTo: view.bounds.height - periodSelectSheetHeight,
            duration: 0.2,
            animation: self.view.layoutIfNeeded
        )
    }
    
    func hidePeriodSheet() {
        guard let viewModel = viewModel else { return }
        
        isModalInPresentation = false
        
        periodSelectSheet.move(
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
            configureCell: self.configureCell,
            configureSupplementaryView: self.configureHeader
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

    func configureHeader(
        _ dataSource: CollectionViewSectionedDataSource<CalendarDates>,
        _ collectionView: UICollectionView,
        _ kind: String,
        _ indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: CalendarHeaderView.identifier,
                  for: indexPath
              ) as? CalendarHeaderView else {
            return UICollectionReusableView()
        }

        let baseDate = Calendar.current.date(
            byAdding: .month,
            value: indexPath.section,
            to: Date()) ?? Date()

        header.configure(with: baseDate)

        return header
    }
}
