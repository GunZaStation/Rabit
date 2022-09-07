import UIKit

final class CalendarView: UIView {
    let monthCollectionView: UICollectionView = {
        let screenSize = UIScreen.main.bounds.size

        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: screenSize.width, height: 35)

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return collectionView
    }()

    convenience init() {
        self.init(frame: .zero)

        setupCollectionViewAttributes()
        setupViews()
    }
}

private extension CalendarView {
    func setupViews() {
        addSubview(monthCollectionView)
        monthCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupCollectionViewAttributes() {
        monthCollectionView.showsVerticalScrollIndicator = false
        monthCollectionView.showsHorizontalScrollIndicator = false

        monthCollectionView.register(
            CalendarCell.self,
            forCellWithReuseIdentifier: CalendarCell.identifier
        )

        monthCollectionView.register(
            CalendarHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CalendarHeaderView.identifier
        )
    }
}
