import UIKit
import SnapKit
import RxCocoa
import RxDataSources
import RxSwift

final class GoalListViewController: UIViewController {
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource
    private let goalListDataSource = DataSource<Goal>(
        configureCell: { dataSource, collectionView, indexPath, goalDetail in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoalListCollectionViewCell.identifier,
                                                                for: indexPath) as? GoalListCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(goalDetail: goalDetail)
            
            return cell
        },
        configureSupplementaryView: {(dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: GoalListCollectionViewHeader.identifier,
                                                                               for: indexPath) as? GoalListCollectionViewHeader else {
                return UICollectionReusableView()
            }
            
            let goal = dataSource.sectionModels[indexPath.section]
            header.configure(title: goal.category)
            
            return header
        }
    )
    
    private lazy var goalListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: .zero, left: .zero, bottom: 15, right: .zero)
        layout.itemSize = CGSize(width: view.frame.width*0.85, height: view.frame.height*0.15)
        layout.headerReferenceSize = CGSize(width: view.frame.width*0.85, height: view.frame.height*0.07)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(
            GoalListCollectionViewCell.self,
            forCellWithReuseIdentifier: GoalListCollectionViewCell.identifier
        )
        
        collectionView.register(
            GoalListCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GoalListCollectionViewHeader.identifier
        )
        
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    private var viewModel: GoalListViewModel?
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: GoalListViewModel = GoalListViewModel()) {
        
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bind()
        
        viewModel?.bind()
    }
    
    private func bind() {
        
        viewModel?.categories
            .bind(to: goalListCollectionView.rx.items(dataSource: goalListDataSource))
            .disposed(by: disposeBag)
    }
    
    private func setupViews() {
        
        view.addSubview(goalListCollectionView)
        goalListCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalTo(view).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
}
