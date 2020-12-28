//
//  MultipleLinesFlowLayout.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 适用于多行控件布局的 layout 类（例 TagListView），需要在外部设置 itemSize
class MultipleLinesFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: UICollectionViewDelegateFlowLayout!

    var itemAttributes: [UICollectionViewLayoutAttributes] = []
    var contentHeight: CGFloat = 0

    override func prepare() {
        super.prepare()
        
        contentHeight = 0
        itemAttributes.removeAll()
 
        var originX: CGFloat = 0
        var originY: CGFloat = 0
        
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        for index in 0..<count {
            let indexPath = IndexPath(item: index, section: 0)
            
            let itemSize = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) ?? self.itemSize

            if index == 0 {
                contentHeight += itemSize.height
            }
            
            if (originX + itemSize.width) > collectionView!.width {
                originX = 0
                originY += (minimumLineSpacing + itemSize.height)
                contentHeight += (minimumLineSpacing + itemSize.height)
            }
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: originX, y: originY, width: itemSize.width, height: itemSize.height)
            itemAttributes.append(attributes)
            
            originX += (minimumInteritemSpacing + itemSize.width)
        }
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.width ?? 0, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return (newBounds.width != collectionView?.bounds.width)
    }
}
