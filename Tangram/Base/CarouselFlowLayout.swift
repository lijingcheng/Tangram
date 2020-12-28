//
//  CarouselFlowLayout.swift
//  Tangram
//
//  Created by 李京城 on 2020/12/25.
//  Copyright © 2020 李京城. All rights reserved.
//

import UIKit

/// 用于 collectionView 的视差滚动效果，需要在使用 layout 的类里设置 itemSize
public class CarouselFlowLayout: UICollectionViewFlowLayout {
    /// 两侧图片的大小会随 scale 更改比例 ( 0 ~ 1)
    @IBInspectable public var sideItemScale: CGFloat = 1
    
    /// 两侧图片的透明度 ( 0 ~ 1)
    @IBInspectable public var sideItemAlpha: CGFloat = 1
    
    /// 图片间隔
    @IBInspectable public var sideItemSpacing: CGFloat = 0
    
    override public func prepare() {
        super.prepare()
        
        collectionView?.decelerationRate = .fast
        
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets.init(top: 0, left: abs(sideItemSpacing * 2), bottom: 0, right: abs(sideItemSpacing * 2))
        
        let scaledItemOffset = (itemSize.width - ceil(itemSize.width * sideItemScale)) / 2
        minimumLineSpacing = sideItemSpacing - scaledItemOffset
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        let attributess = super.layoutAttributesForElements(in: rect)
        
        attributess?.forEach({ attributes in
            let collectionCenter = collectionView.width / 2
            let normalizedCenter = attributes.center.x - collectionView.contentOffset.x
            
            let maxDistance = self.itemSize.width + self.minimumLineSpacing
            let distance = min(abs(collectionCenter - normalizedCenter), maxDistance)
            let ratio = (maxDistance - distance) / maxDistance
            
            let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
            let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
            
            attributes.alpha = alpha
            attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            attributes.zIndex = Int(alpha * 10)
        })
        
        return attributess
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, let attributes = layoutAttributesForElements(in: collectionView.bounds) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        
        let midSide = floor(collectionView.width / 2)
        let proposedContentOffsetCenterOrigin = proposedContentOffset.x + midSide
        
        let closest = attributes.sorted { abs(ceil($0.center.x) - proposedContentOffsetCenterOrigin) < abs(ceil($1.center.x) - proposedContentOffsetCenterOrigin) }.first ?? UICollectionViewLayoutAttributes()
        
        return CGPoint(x: floor(closest.center.x - midSide), y: proposedContentOffset.y)
    }
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
