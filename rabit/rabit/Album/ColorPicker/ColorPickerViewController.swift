import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ColorPickerViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Colors"
        return label
    }()

    private let presetColorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()


    private var viewModel: ColorPickerViewModelProtocol?

    private var disposeBag = DisposeBag()

    convenience init(viewModel: ColorPickerViewModelProtocol) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setAttributes()
        setupPresetColorCollectionView()
        bind()
    }
}

private extension ColorPickerViewController {
    func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(presetColorCollectionView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(20)
        }

        presetColorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().inset(20)
        }
    }

    func setAttributes() {
        view.backgroundColor = UIColor(named: "first")
        setupNavigationBarButton()
    }

    func bind() {
        guard let viewModel = viewModel else { return }

        Observable.of(viewModel.presetColors)
            .bind(to: presetColorCollectionView.rx.items(
                cellIdentifier: PresetColorCell.identifier,
                cellType: PresetColorCell.self
            )) { _, element, cell in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)

        presetColorCollectionView.rx.modelSelected(String.self)
            .bind(to: viewModel.selectedColor)
            .disposed(by: disposeBag)

        navigationItem.leftBarButtonItem?.rx.tap
            .bind(to: viewModel.backButtonTouched)
            .disposed(by: disposeBag)
    }

    func setupPresetColorCollectionView() {
        let layout = CompositionalLayoutFactory.shared.create(
            widthFraction: 1/6,
            heightFraction: 1/6,
            spacing: Spacing(top: 5, bottom: 5, left: 5, right: 5)
        )

        presetColorCollectionView.collectionViewLayout = layout

        presetColorCollectionView.register(
            PresetColorCell.self,
            forCellWithReuseIdentifier: PresetColorCell.identifier
        )
    }

    func setupNavigationBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(
                systemName: "chevron.backward",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 18,
                    weight: .semibold)
                ),
            style: .plain,
            target: nil, action: nil
        )
    }
}
