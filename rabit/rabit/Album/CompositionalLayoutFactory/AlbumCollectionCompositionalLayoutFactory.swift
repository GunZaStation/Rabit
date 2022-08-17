import UIKit

final class AlbumCollectionCompositionalLayoutFactory {
    static let shared = AlbumCollectionCompositionalLayoutFactory()

    private init() { }

    func create() -> NSCollectionLayoutSection {
        let itemFractionalWidthFraction = 1.0

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemFractionalWidthFraction),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1)
                ),
            subitems: [item]
        )

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50.0)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)

        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .paging

        return section
    }
}
