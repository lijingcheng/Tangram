//
//  BannerView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// 轮播图，图片默认三秒一换
class BannerCell: UICollectionViewCell {
    static var reuseIdentifier = "bannerCellId"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill // 默认模式会破坏图片比例，目前保持图片比例不变，并且填充视图
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: 0xEDEEEF)
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

public class BannerView: UIView {
    public var items: [String] = [] {
        didSet {
            if items.count > 1 {
                var newItems = items
                newItems.insert(items.last!, at: 0)
                newItems.append(items.first!)
                items = newItems
            }
        }
    }
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        
        return pageControl
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor(hex: 0xEDEEEF)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        pageControl.frame = CGRect(x: 0, y: height - 30, width: width, height: 30)
        
        if pageControl.numberOfPages > 1, items.count > 1 {
            DispatchQueue.once(token: UUID().uuidString) {
                collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: [], animated: false)
            }
        }
    }
    
    deinit {
        stopPlay()
    }
    
    // MARK: -
    public func selectedItemHandler(_ selectedItemHandler: @escaping (_ index: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
    
    private func setupViews() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    fileprivate func startPlay() {
        if items.count > 1 {
            stopPlay()
            
            perform(#selector(nextPage), with: nil, afterDelay: 3)
        }
    }
    
    fileprivate func stopPlay() {
        collectionView.layer.removeAnimation(forKey: "scrollAnimation")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(nextPage), object: nil)
    }
    
    @objc func nextPage() {
        var currentPage = pageControl.currentPage
        
        if pageControl.currentPage == (items.count - 3) {
            currentPage = 0
        } else {
            currentPage += 1
        }
        
        let animation = CATransition()
        animation.duration = 0.3
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromRight
        
        collectionView.setContentOffset(CGPoint(x: CGFloat(currentPage + 1) * collectionView.width, y: 0), animated: false)
        collectionView.layer.add(animation, forKey: "scrollAnimation")
        pageControl.currentPage = currentPage
        
        startPlay()
    }
    
    public func reloadData() {
        stopPlay()
        
        collectionView.reloadData {
            if self.items.count > 1 {
                self.collectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: [], animated: false)
            }
            
            self.startPlay()
        }
    }
}

// MARK: -
extension BannerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = items.count <= 1 ? items.count : (items.count - 2)
        pageControl.currentPage = 0
        
        setNeedsLayout()
        
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.reuseIdentifier, for: indexPath) as! BannerCell
        cell.imageView.setImageURL(items[indexPath.item])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = (indexPath.item > 0) ? indexPath.item - 1 : 0
        
        selectedItemHandler?(index)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopPlay() // 开始拖动时停止自动滚动
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var currentPage = Int(abs(scrollView.contentOffset.x / scrollView.width))
        
        // 因为数据源比实际数据多2个，所以第一页和最后一页时需要干预 currentPage 的取值方式
        if currentPage == 0 {
            currentPage = items.count - 3
            collectionView.contentOffset = CGPoint(x: CGFloat((items.count - 2)) * collectionView.width, y: 0)
        } else if currentPage == items.count - 1 {
            currentPage = 0
            collectionView.contentOffset = CGPoint(x: collectionView.width, y: 0)
        } else {
            currentPage -= 1
        }
        
        pageControl.currentPage = currentPage
        
        startPlay()
    }
}
