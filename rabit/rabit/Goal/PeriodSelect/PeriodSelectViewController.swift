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
    private var viewModel: PeriodSelectViewModel?

    private var countSelectedCell = 2
    
    convenience init(viewModel: PeriodSelectViewModel) {
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

        calendarCollectionView.rx.modelSelected(CalendarDate.self)
            .withUnretained(self)
            .bind { viewController, data in
                let isSelectable = !data.isBeforeToday

                viewController.countSelectedCell += (isSelectable) ? 1 : 0
            }
            .disposed(by: disposeBag)

        calendarCollectionView.rx.itemSelected
            .withUnretained(self)
            .withLatestFrom(viewModel.calendarData) {
                var dayData = $1
                let isSelectable = !dayData[$0.1.section].items[$0.1.item].isBeforeToday

                if $0.0.countSelectedCell > 2 {
                    $0.0.countSelectedCell = 1
                    dayData = dayData.map {
                        var temp = $0
                        temp.resetDaysSelectedState()
                        return temp
                    }
                }

                dayData[$0.1.section].items[$0.1.item].isSelected = isSelectable

                return dayData
            }
            .bind(to: viewModel.calendarData)
            .disposed(by: disposeBag)

        calendarCollectionView.rx.modelSelected(CalendarDate.self)
            .filter { $0.isSelected == true }
            .bind(to: viewModel.selectedDate)
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

        var itemData = dataSource.sectionModels[indexPath.section].items[indexPath.item]
        let isInitialState = (countSelectedCell != 1)

        if isInitialState {
            /**
             처음 PeriodSelectVC가 화면에 나온 상황에서, periodStream으로부터 받아온 Period의 값이 저장된 selectedPeriod.value로부터 시작일과 종료일을 먼저 calendarCollectionView에 표시해놓기 위한 로직입니다.
             해당 처리를 여기서 하는 이유는, periodStream의 value인 Period를 viewModel내에서 selected 처리를 하기 위해서는
             index를 찾고 찾아 그 데이터의 `isSelected = true` 처리를 해야하는 복잡한 과정이 필요했기 때문에,
             cell을 configure 해주는 위치에서, 현재 상황이 initial State인지, 그리고 표시하려는 cell에 해당하는 모델 데이터의 date를 확인해 표시해주는 로직을 구현.
             **/
            let isStartDate = itemData.date.isSameDate(with: periodData.start)
            let isEndDate = itemData.date.isSameDate(with: periodData.end)

            itemData.isSelected = isStartDate || isEndDate
        }

        cell.configure(with: itemData)
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
