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
    
    private let calendarView = CalendarView()
    
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
    
    private lazy var dataSource: RxCollectionViewSectionedReloadDataSource<Days> = {
        initializeDataSource()
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: PeriodSelectViewModel?
    
    convenience init(viewModel: PeriodSelectViewModel) {
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
        
        viewModel.dayData
            .bind(to: calendarView.monthCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        calendarView.monthCollectionView.rx.itemSelected
            .withLatestFrom(viewModel.dayData) {
                var dayData = $1
                let isSelected = dayData[$0.section].items[$0.item].isSelected

                dayData[$0.section].items[$0.item].isSelected = !isSelected

                return dayData
            }
            .bind(to: viewModel.dayData)
            .disposed(by: disposeBag)

        calendarView.monthCollectionView.rx.modelSelected(Day.self)
            .filter { $0.isSelected == true }
            .bind(to: viewModel.selectedDay)
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
        
        view.addSubview(periodSheet)
        periodSheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.snp.bottom)
        }
        
        periodSheet.contentView.addSubview(calendarView)
        calendarView.snp.makeConstraints {
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

    func initializeDataSource() -> RxCollectionViewSectionedReloadDataSource<Days> {
        let configureCell: (CollectionViewSectionedDataSource<Days>, UICollectionView, IndexPath, Days.Item) -> UICollectionViewCell = { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarCell.identifier,
                for: indexPath
            ) as? CalendarCell else { return UICollectionViewCell() }

            let itemData = dataSource.sectionModels[indexPath.section].items[indexPath.item]

            cell.configure(with: itemData)
            return cell
        }

        let configureHeaderView: (CollectionViewSectionedDataSource<Days>, UICollectionView, String, IndexPath) -> UICollectionReusableView = {
            (dataSource, collectionView, kind, indexPath) in
               guard kind == UICollectionView.elementKindSectionHeader,
                     let header = collectionView.dequeueReusableSupplementaryView(
                         ofKind: kind,
                         withReuseIdentifier: CalendarHeaderView.identifier,
                         for: indexPath
                     ) as? CalendarHeaderView else {
                   return UICollectionReusableView()
               }

            let baseDate = Calendar.current.date(byAdding: .month, value: indexPath.section, to: Date()) ?? Date()
            header.configure(with: baseDate)

            return header
        }

        let dataSource = RxCollectionViewSectionedReloadDataSource<Days>(
            configureCell: configureCell,
            configureSupplementaryView: configureHeaderView
        )

        return dataSource
    }
}

