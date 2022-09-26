import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CalendarView: UIView {
    let calendarCollectionView: UICollectionView = {
        let screenSize = UIScreen.main.bounds
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenSize.width/10, height: screenSize.width/10)
        layout.sectionInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    private let headerStackView: UIStackView = {
        let screenWidth = UIScreen.main.bounds.width
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 20/414 * screenWidth
        return stackView
    }()

    private let calendarInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        return stackView
    }()

    private let yearLabel: UILabel = {
        let screenHeight = UIScreen.main.bounds.height
        let initialYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 2022
        let label = UILabel()
        label.font = .systemFont(ofSize: 15/896 * screenHeight, weight: .regular)
        label.text = "\(initialYear)"
        return label
    }()

    private let monthLabel: UILabel = {
        let screenHeight = UIScreen.main.bounds.height
        let initialMonth = Calendar.current.dateComponents([.month], from: Date()).month ?? 0
        let label = UILabel()
        label.font = .systemFont(ofSize: 40/896 * screenHeight, weight: .medium)
        label.text = "\(initialMonth)"
        return label
    }()

    private let nextMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = UIColor(named: "second")
        return button
    }()

    private let prevMonthButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = UIColor(named: "second")
        return button
    }()

    private var disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        setupViews()
        setupCollectionViewAttributes()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
        setupCollectionViewAttributes()
    }

    func bind(to viewModel: PeriodSelectViewModelProtocol) {
        calendarCollectionView.rx.itemSelected
            .withLatestFrom(
                calendarCollectionView.rx.modelSelected(CalendarDates.Item.self),
                resultSelector: { ($0,$1) }
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

        prevMonthButton.rx.tap
            .bind(to: viewModel.prevMonthButtonTouched)
            .disposed(by: disposeBag)

        nextMonthButton.rx.tap
            .bind(to: viewModel.nextMonthButtonTouched)
            .disposed(by: disposeBag)

        viewModel.prevMonthButtonTouched
            .withUnretained(self.calendarCollectionView)
            .bind { collectionView, _ in
                let prevSection = collectionView.indexPathsForVisibleItems[0].section-1
                let numberOfCells = collectionView.numberOfItems(inSection: prevSection)

                collectionView.scrollToItem(
                    at: IndexPath(item: numberOfCells-1, section: prevSection),
                    at: .bottom,
                    animated: true
                )
            }
            .disposed(by: disposeBag)

        viewModel.nextMonthButtonTouched
            .withUnretained(self.calendarCollectionView)
            .bind { collectionView, _ in
                let nextSection = collectionView.indexPathsForVisibleItems[0].section+1
                let numberOfCells = collectionView.numberOfItems(inSection: nextSection)

                collectionView.scrollToItem(
                    at: IndexPath(item: numberOfCells-1, section: nextSection),
                    at: .bottom,
                    animated: true
                )
            }
            .disposed(by: disposeBag)

        calendarCollectionView.rx.didEndScrollingAnimation
            .withUnretained(self.calendarCollectionView)
            .map { collectionView, _ in
                let prevSection = collectionView.indexPathsForVisibleItems[0].section-1
                return prevSection >= 0
            }
            .bind(to: viewModel.prevMonthButtonState)
            .disposed(by: disposeBag)

        calendarCollectionView.rx.didEndScrollingAnimation
            .withUnretained(self.calendarCollectionView)
            .map { collectionView, _ in
                let nextSection = collectionView.indexPathsForVisibleItems[0].section+1
                let countSections = collectionView.numberOfSections
                return nextSection < countSections
            }
            .bind(to: viewModel.nextMonthButtonState)
            .disposed(by: disposeBag)

        viewModel.prevMonthButtonState
            .bind(to: prevMonthButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.nextMonthButtonState
            .bind(to: nextMonthButton.rx.isEnabled)
            .disposed(by: disposeBag)

        let currentCalendarData = calendarCollectionView.rx.didEndScrollingAnimation
            .withUnretained(self.calendarCollectionView)
            .map { (collectionView, _) -> DateComponents in
                let referenceIndexPath = collectionView.indexPathsForVisibleItems[0]
                let referenceData = viewModel.calendarData.value[referenceIndexPath.section].items[referenceIndexPath.item].date

                return Calendar.current.dateComponents([.year, .month], from: referenceData)
            }

        currentCalendarData
            .compactMap(\.year)
            .map(String.init)
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)

        currentCalendarData
            .compactMap(\.month)
            .map(String.init)
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

private extension CalendarView {
    func setupViews() {
        calendarInfoStackView.addArrangedSubview(yearLabel)
        calendarInfoStackView.addArrangedSubview(monthLabel)

        headerStackView.addArrangedSubview(prevMonthButton)
        headerStackView.addArrangedSubview(calendarInfoStackView)
        headerStackView.addArrangedSubview(nextMonthButton)
        addSubview(headerStackView)
        headerStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        addSubview(calendarCollectionView)
        calendarCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setupCollectionViewAttributes() {
        calendarCollectionView.register(
            CalendarCell.self,
            forCellWithReuseIdentifier: CalendarCell.identifier
        )
    }
}
