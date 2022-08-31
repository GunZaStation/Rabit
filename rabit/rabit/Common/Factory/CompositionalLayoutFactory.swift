import UIKit

struct Spacing {
    
    let top: CGFloat
    let bottom: CGFloat
    let left: CGFloat
    let right: CGFloat
    
    init(
        top: CGFloat = .zero,
        bottom: CGFloat = .zero,
        left: CGFloat = .zero,
        right: CGFloat = .zero
    ) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }
}

final class CompositionalLayoutFactory {
    static let shared = CompositionalLayoutFactory()
    
    private init() { }
    
    func create(widthFraction: CGFloat,
                heightFraction: CGFloat,
                spacing: Spacing = Spacing(),
                groupWidthFraction: CGFloat = 1.0,
                requireHeader: Bool = false,
                headerWidth: CGFloat = .zero,
                headerHeight: CGFloat = .zero,
                requireFooter: Bool = false,
                footerWidth: CGFloat = .zero,
                footerHeight: CGFloat = .zero,
                enableScrolling: Bool = false,
                sectionHandler: (([NSCollectionLayoutVisibleItem], CGPoint, NSCollectionLayoutEnvironment) -> Void)? = nil ) -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { section, _ in
            self.section(
                widthFraction: widthFraction,
                heightFraction: heightFraction,
                spacing: spacing,
                groupWidthFraction: groupWidthFraction,
                requireHeader: requireHeader,
                headerWidth: headerWidth,
                headerHeight: headerHeight,
                requireFooter: requireFooter,
                footerWidth: footerWidth,
                footerHeight: footerHeight,
                enableScrolling: enableScrolling,
                sectionHandler: sectionHandler
            )
        }
    }
}

private extension CompositionalLayoutFactory {
    
    func section(widthFraction: CGFloat,
                 heightFraction: CGFloat,
                 spacing: Spacing,
                 groupWidthFraction: CGFloat,
                 requireHeader: Bool,
                 headerWidth: CGFloat,
                 headerHeight: CGFloat,
                 requireFooter: Bool,
                 footerWidth: CGFloat,
                 footerHeight: CGFloat,
                 enableScrolling: Bool,
                 sectionHandler: (([NSCollectionLayoutVisibleItem], CGPoint, NSCollectionLayoutEnvironment) -> Void)?) -> NSCollectionLayoutSection {
        
        let widthFraction = widthFraction
        let heightFraction = heightFraction
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(widthFraction),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: spacing.top,
            leading: spacing.left,
            bottom: spacing.bottom,
            trailing: spacing.right
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(groupWidthFraction),
            heightDimension: .fractionalHeight(heightFraction)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = []

        if(enableScrolling) {
            section.orthogonalScrollingBehavior = .groupPagingCentered
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

        if let sectionHandler = sectionHandler {
            section.visibleItemsInvalidationHandler = sectionHandler
        }

        return section
    }
}
