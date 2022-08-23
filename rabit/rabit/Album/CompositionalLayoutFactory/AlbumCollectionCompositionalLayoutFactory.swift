import UIKit

final class AlbumCollectionCompositionalLayoutFactory {
    static let shared = AlbumCollectionCompositionalLayoutFactory()
    
    private init() { }
    
    func create(widthFraction: CGFloat,
                heightFraction: CGFloat,
                topSpacing: CGFloat = .zero,
                bottomSpacing: CGFloat = .zero,
                leftSpacing: CGFloat = .zero,
                rightSpacing: CGFloat = .zero,
                requireHeader: Bool = false,
                headerWidth: CGFloat = .zero,
                headerHeight: CGFloat = .zero,
                requireFooter: Bool = false,
                footerWidth: CGFloat = .zero,
                footerHeight: CGFloat = .zero,
                enableScrolling: Bool = false) -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { section, _ in
            self.section(
                widthFraction: widthFraction,
                heightFraction: heightFraction,
                topSpacing: topSpacing,
                bottomSpacing: bottomSpacing,
                leftSpacing: leftSpacing,
                rightSpacing: rightSpacing,
                requireHeader: requireHeader,
                headerWidth: headerWidth,
                headerHeight: headerHeight,
                requireFooter: requireFooter,
                footerWidth: footerWidth,
                footerHeight: footerHeight,
                enableScrolling: enableScrolling
            )
        }
    }
}

extension AlbumCollectionCompositionalLayoutFactory {
    
    private func section(widthFraction: CGFloat,
                         heightFraction: CGFloat,
                         topSpacing: CGFloat,
                         bottomSpacing: CGFloat,
                         leftSpacing: CGFloat,
                         rightSpacing: CGFloat,
                         requireHeader: Bool,
                         headerWidth: CGFloat,
                         headerHeight: CGFloat,
                         requireFooter: Bool,
                         footerWidth: CGFloat,
                         footerHeight: CGFloat,
                         enableScrolling: Bool) -> NSCollectionLayoutSection {
        
        let widthFraction = widthFraction
        let heightFraction = heightFraction
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(widthFraction),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: topSpacing,
            leading: leftSpacing,
            bottom: bottomSpacing,
            trailing: rightSpacing
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(heightFraction)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = []
        
        if(enableScrolling) {
            section.orthogonalScrollingBehavior = .groupPaging
        }
        
        if(requireHeader) {
            let headerItemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(headerWidth),
                heightDimension: .absolute(headerHeight)
            )
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerItemSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            section.boundarySupplementaryItems.append(headerItem)
        }
        
        if(requireFooter) {
            let footerItemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(footerWidth),
                heightDimension: .absolute(footerHeight)
            )
            
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerItemSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            
            section.boundarySupplementaryItems.append(footerItem)
        }
        
        return section
    }
}
