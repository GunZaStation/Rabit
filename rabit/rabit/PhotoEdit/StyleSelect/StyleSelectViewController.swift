import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class StyleSelectViewController: UIViewController {
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.isHidden = true
        return view
    }()

    private lazy var styleSheetHeight = view.bounds.height * 0.65
    private lazy var styleSheet: BottomSheet = {
        let screenSize = UIScreen.main.bounds
        let sheet = BottomSheet(screenSize.height, styleSheetHeight)
        sheet.backgroundColor = .white
        sheet.roundCorners(20)
        return sheet
    }()

    private let styleSelectCollectionView: UICollectionView = {
        let screenSize = UIScreen.main.bounds.size
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenSize.width * 0.8, height: screenSize.width * 0.9)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 0)

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.roundCorners()
        button.setBackgroundColor(UIColor(named: "third"), for: .normal)
        button.setBackgroundColor(.systemGray3, for: .disabled)
        return button
    }()

    private var viewModel: StyleSelectViewModelProtocol?

    private var disposeBag = DisposeBag()

    convenience init(viewModel: StyleSelectViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupStyleSelectCollectionView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showStyleSheet()
    }
}

private extension StyleSelectViewController {
    func setupViews() {
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(styleSheet)
        styleSheet.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.bounds.height)
            make.height.equalTo(styleSheetHeight)
            make.leading.trailing.equalToSuperview()
        }

        styleSheet.contentView.addSubview(styleSelectCollectionView)
        styleSelectCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
        }

        styleSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(styleSelectCollectionView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        Observable.of(viewModel.presetStyles)
            .bind(to: styleSelectCollectionView.rx.items(
                cellIdentifier: StyleSelectCell.identifier,
                cellType: StyleSelectCell.self
            )) { [weak self] index, element, cell in
                self?.presentSelectedCell(index: index, data: element)
                var photo = viewModel.appliedPhotoWithSelectedStyle.value
                photo.style = element
                cell.configure(with: photo)
            }
            .disposed(by: disposeBag)

        styleSelectCollectionView.rx.modelSelected(Style.self)
            .withLatestFrom(viewModel.appliedPhotoWithSelectedStyle) {
                var photo = $1
                photo.style = $0
                return photo
            }
            .bind(to: viewModel.appliedPhotoWithSelectedStyle)
            .disposed(by: disposeBag)

        styleSelectCollectionView.rx.itemSelected
            .withUnretained(self.styleSelectCollectionView)
            .bind { collectionView, selectedIndexPath in
                collectionView.scrollToItem(
                    at: selectedIndexPath,
                    at: .centeredHorizontally,
                    animated: true
                )
            }
            .disposed(by: disposeBag)

        dimmedView.rx.tapGesture()
            .when(.ended)
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hideStyleSheet()
            }
            .disposed(by: disposeBag)

        styleSheet.rx.isClosed
            .withUnretained(self)
            .bind { viewController, _ in
                viewController.hideStyleSheet()
            }
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .throttle(.milliseconds(400), scheduler: MainScheduler.instance)
            .withUnretained(self) { viewController, _ in
                viewController.hideStyleSheet()
            }
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)

        viewModel.saveButtonState
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    func setupStyleSelectCollectionView() {
        styleSelectCollectionView.register(
            StyleSelectCell.self,
            forCellWithReuseIdentifier: StyleSelectCell.identifier
        )
    }

    func showStyleSheet() {
        dimmedView.isHidden = false

        styleSheet.move(
            upTo: view.bounds.height - styleSheetHeight,
            duration: 0.2,
            animation: view.layoutIfNeeded
        )
    }

    func hideStyleSheet() {
        guard let viewModel = viewModel else { return }

        styleSheet.move(
            upTo: view.bounds.height,
            duration: 0.2,
            animation: view.layoutIfNeeded
        ) { _ in
            self.dimmedView.isHidden = true
            viewModel.closeStyleSelectRequested.accept(())
        }
    }

    func presentSelectedCell(index: Int, data: Style) {
        let isSelected = (viewModel?.appliedPhotoWithSelectedStyle.value.style == data)

        if isSelected {
            styleSelectCollectionView.selectItem(
                at: IndexPath(item: index, section: 0),
                animated: false,
                scrollPosition: .init()
            )
        }
    }
}
