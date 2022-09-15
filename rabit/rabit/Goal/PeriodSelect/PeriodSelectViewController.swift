import UIKit
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
    
    private let calendarCollectionView: UICollectionView = {
        let screenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()
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
    
    private lazy var saveButton: UIButton = {
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
        setupCollectionViewAttributes()
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
            .bind(to: calendarCollectionView.rx.items(dataSource: dataSource))
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
        
        periodSheet.contentView.addSubview(calendarCollectionView)
        calendarCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.8)
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
            upTo: view.bounds.height*0.4,
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
            configureCell: self.configureCell,
            configureSupplementaryView: self.configureHeaderView
        )
    }

    func setupCollectionViewAttributes() {
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

    func configureHeaderView(
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
