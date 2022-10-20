import UIKit
import SnapKit
import RxSwift

final class GoalListCollectionViewHeader: UICollectionReusableView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.setTitleColor(UIColor.white, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 15
        return button
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    func bind(viewModel: GoalListViewModelProtocol?, category: Category) {
        guard let viewModel = viewModel else { return }
        disposeBag = DisposeBag()
        
        addButton.rx.tap
            .map { category }
            .bind(to: viewModel.goalAddButtonTouched)
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addSubview(addButton)
        addButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
            $0.trailing.equalToSuperview().inset(10)
        }
    }
}
