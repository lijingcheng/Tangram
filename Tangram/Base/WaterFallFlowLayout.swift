//
//  WaterFallFlowLayout.swift
//  Tangram
//
//  Created by 李京城 on 2020/12/25.
//  Copyright © 2020 李京城. All rights reserved.
//

import UIKit

/// 适用于瀑布流布局的 layout 类，需要在外部设置 itemSize 和 columnCount（列数）
public class WaterFallFlowLayout: UICollectionViewFlowLayout {
    
    public weak var delegate: UICollectionViewDelegateFlowLayout!
    public var columnCount = 0
    
    var contentHeight: CGFloat = 0
    var itemAttributes: [UICollectionViewLayoutAttributes] = []

    public override func prepare() {
        super.prepare()
        
        contentHeight = 0
        itemAttributes.removeAll()
 
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        var columnHeights = Array(repeating: sectionInset.top, count: columnCount)
    
        let itemCount = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        for index in 0..<itemCount {
            guard let shortestHeight = columnHeights.min() else {
                return
            }
            
            let indexPath = IndexPath(item: index, section: 0)
            let itemSize = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) ?? self.itemSize
            let shortestIndex = columnHeights.firstIndex(of: shortestHeight) ?? 0
                   
            originX = sectionInset.left + ((itemSize.width + minimumInteritemSpacing) * CGFloat(shortestIndex))
            originY = shortestHeight
            columnHeights[shortestIndex] = shortestHeight + minimumLineSpacing + itemSize.height
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: originX, y: originY, width: itemSize.width, height: itemSize.height)
            itemAttributes.append(attributes)
        }
        
        if let longestHeight = columnHeights.max() {
            contentHeight = longestHeight
        }
    }

    public override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.width ?? 0, height: contentHeight)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemAttributes
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return (newBounds.width != collectionView?.bounds.width)
    }
}
