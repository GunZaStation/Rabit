import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class ColorSelectViewController: UIViewController {
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.isHidden = true
        return view
    }()

    private lazy var colorSheetHeight = view.bounds.height * 0.5
    private lazy var colorSheet: BottomSheet = {
        let sheet = BottomSheet(view.bounds.height, colorSheetHeight)
        sheet.backgroundColor = .white
        sheet.roundCorners(20)
        return sheet
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Colors"
        return label
    }()

    private let colorSelectCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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


    private var viewModel: ColorSelectViewModelProtocol?

    private var disposeBag = DisposeBag()

    convenience init(viewModel: ColorSelectViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupColorSelectCollectionView()
        bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showColorSheet()
    }
}

private extension ColorSelectViewController {
    func setupViews() {
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(colorSheet)
        colorSheet.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(view.bounds.height)
            make.height.equalTo(colorSheetHeight)
            make.leading.trailing.equalToSuperview()
        }

        colorSheet.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        colorSheet.contentView.addSubview(colorSelectCollectionView)
        colorSelectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(220)
        }

        colorSheet.contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(colorSelectCollectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        Observable.of(viewModel.presetColors)
            .bind(to: colorSelectCollectionView.rx.items(
                cellIdentifier: ColorSelectCell.identifier,
                cellType: ColorSelectCell.self
            )) { [weak self] index, element, cell in
                self?.presentSelectedCell(index: index, data: element)
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)

        colorSelectCollectionView.rx.modelSelected(String.self)
            .bind(to: viewModel.selectedColor)
            .disposed(by: disposeBag)

        dimmedView.rx.tapGesture()
            .when(.ended)
            .withUnretained(self)
            .bind(onNext: { viewController, _ in
                viewController.hideColorSheet()
            })
            .disposed(by: disposeBag)

        colorSheet.rx.isClosed
            .bind(to: viewModel.closeColorSelectRequested)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .withUnretained(self) { viewController, _ in
                viewController.hideColorSheet()
            }
            .bind(to: viewModel.saveButtonTouched)
            .disposed(by: disposeBag)

        viewModel.saveButtonState
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    func setupColorSelectCollectionView() {
        let layout = CompositionalLayoutFactory.shared.create(
            widthFraction: 1/5,
            heightFraction: 1/5,
            spacing: Spacing(top: 5, bottom: 5, left: 5, right: 5)
        )

        colorSelectCollectionView.collectionViewLayout = layout

        colorSelectCollectionView.register(
            ColorSelectCell.self,
            forCellWithReuseIdentifier: ColorSelectCell.identifier
        )
    }

    func showColorSheet() {
        dimmedView.isHidden = false

        colorSheet.move(
            upTo: view.bounds.height - colorSheetHeight,
            duration: 0.2,
            animation: view.layoutIfNeeded
        )

        navigationController?.hidesBottomBarWhenPushed = true
    }
    
    func hideColorSheet() {
        guard let viewModel = viewModel else { return }

        colorSheet.move(
            upTo: view.bounds.height,
            duration: 0.2,
            animation: view.layoutIfNeeded
        ) { _ in
            self.dimmedView.isHidden = true
            viewModel.closeColorSelectRequested.accept(())
        }
    }

    func presentSelectedCell(index: Int, data: String) {
        let isSelected = (viewModel?.selectedColor.value == data)

        if isSelected {
            colorSelectCollectionView.selectItem(
                at: IndexPath(item: index, section: 0),
                animated: false,
                scrollPosition: .init()
            )
        }
    }
}
