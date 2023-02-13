//
//  PageControl.swift
//  Tangram
//
//  Created by 李京城 on 2022/7/7.
//  Copyright © 2022 李京城. All rights reserved.
//

import UIKit

class PageControlCell: UICollectionViewCell {
    static let reuseIdentifier = "PageControlCellId"
    
    var imageView: UIImageView = {
        return UIImageView(frame: .zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}

public class PageControl: UIView {
    /// 当前选中图标
    public var indicatorImage = UIImage(named: "icon_dot_selected", in: .tangram, compatibleWith: nil) {
        didSet {
            collectionView.reloadData()
        }
    }

    /// 默认图标
    public var preferredIndicatorImage = UIImage(named: "icon_dot_unselected", in: .tangram, compatibleWith: nil) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /// 一共多少页
    public var numberOfPages = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /// item 间距
    public var itemSpacing = 2.5 {
        didSet {
            let layout = collectionView.collectionViewLayout as? SingleLineFlowLayout
            layout?.minimumInteritemSpacing = itemSpacing
            
            collectionView.reloadData()
        }
    }
    
    /// 当前页 index
    public var currentPage = 0 {
        didSet {
            if currentPage >= 0 && numberOfPages > 1 && currentPage < numberOfPages {
                collectionView.reloadData()
            }
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = SingleLineFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = 10000
        layout.delegate = self
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = false
        collectionView.register(PageControlCell.self, forCellWithReuseIdentifier: PageControlCell.reuseIdentifier)
        
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        isUserInteractionEnabled = false
        
        addSubview(collectionView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
    
    /// 使用 PageControl 时需要在 layoutSubViews 里调用此方法来得到控件实际大小，然后再确定摆放位置
    public func sizeForNumberOfPages() -> CGSize {
        guard numberOfPages > 1 else {
            return .zero
        }
        
        let indicatorImageSize = indicatorImage?.size ?? .zero
        let preferredIndicatorImageSize = preferredIndicatorImage?.size ?? .zero

        let width = ceil(indicatorImageSize.width) + (ceil(preferredIndicatorImageSize.width) * CGFloat(numberOfPages - 1)) + (itemSpacing * CGFloat(numberOfPages - 1))
        
        return CGSize(width: width, height: max(ceil(indicatorImageSize.height), ceil(preferredIndicatorImageSize.height)))
    }
}

extension PageControl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfPages > 1 ? numberOfPages : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = ((indexPath.item == currentPage) ? indicatorImage?.size : preferredIndicatorImage?.size) ?? .zero
        
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageControlCell.reuseIdentifier, for: indexPath) as! PageControlCell
        cell.imageView.image = (indexPath.item == currentPage) ? indicatorImage : preferredIndicatorImage
        
        return cell
    }
}

public class SingleLineFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: UICollectionViewDelegateFlowLayout!

    var itemAttributes: [UICollectionViewLayoutAttributes] = []
    var contentHeight: CGFloat = 0

    public override func prepare() {
        super.prepare()
        
        contentHeight = 0
        itemAttributes.removeAll()
 
        var originX: CGFloat = 0
        
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        for index in 0..<count {
            let indexPath = IndexPath(item: index, section: 0)
            
            let itemSize = delegate.collectionView?(collectionView!, layout: self, sizeForItemAt: indexPath) ?? self.itemSize
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(x: originX, y: 0, width: itemSize.width, height: itemSize.height)
            itemAttributes.append(attributes)
            
            contentHeight = max(contentHeight, itemSize.height)
            originX += (minimumInteritemSpacing + itemSize.width)
        }
        
        itemAttributes.forEach { attribute in
            attribute.frame.origin = CGPoint(x: attribute.frame.origin.x, y: (contentHeight - attribute.frame.height) / 2)
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
