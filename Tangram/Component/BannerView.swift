//
//  BannerView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

public enum PageControlAlignment: Int {
    case left, center, right
}

/// 轮播图，图片默认三秒一换
class BannerCell: UICollectionViewCell {
    static var reuseIdentifier = "bannerCellId"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(hex: 0xEDEEEF)
        contentView.clipsToBounds = true
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

/// BannerPageControl 样式
public enum BannerPageControlStyle: Int {
    case dot, text, none
}

public class BannerView: UIView {
    /// 默认图不要传整张大图，而是传显示在控件中间的小图
    @objc public var placeholder: UIImage?
    
    /// 图片滚动间隔，默认三秒
    public var interval = 3
    
    /// 是否自动滚动，默认为 true
    @objc public var autoRolling = true
    
    /// 是否循环滚动，默认为 true
    public var supportCircularlyRolling = true
    
    /// 如果页面需要固定 item 宽度而不是根据屏幕自适应宽度可以主动设置 itemSize
    public var itemSize: CGSize?
    
    /// 图片加圆角
    @objc public var itemCornerRadius: CGFloat = 0
    
    /// 图片的填充方式（默认 .scaleAspectFill）
    public var imageContentMode: ContentMode = .scaleAspectFill
    
    /// 两侧图片的大小会随 scale 更改比例
    public var sideItemScale: CGFloat = 1 {
        didSet {
            useCarouselFlowLayout()
        }
    }
    
    /// 两侧图片的透明度
    public var sideItemAlpha: CGFloat = 0.6 {
        didSet {
            useCarouselFlowLayout()
        }
    }
    
    /// 图片间隔
    @objc public var sideItemSpacing: CGFloat = 0 {
        didSet {
            useCarouselFlowLayout()
        }
    }
    
    /// pageControl 样式，默认是小圆点
    public var pageControlStyle = BannerPageControlStyle.dot {
        didSet {
            if pageControlStyle == .text {
                pageControl.removeFromSuperview()
                
                addSubview(pagePromptView)
            } else if pageControlStyle == .none {
                pageControl.removeFromSuperview()
                pagePromptView.removeFromSuperview()
            }
        }
    }
    
    /// PageControl 控件在 Banner 上的位置
    public var pageControlAlignment: PageControlAlignment = .left
    
    @objc public var items: [Any] = [] {
        didSet {
            if supportCircularlyRolling, items.count > 1 {
                var newItems = items
                newItems.insert(items.last!, at: 0)
                newItems.append(items.first!)
                items = newItems
            }
        }
    }
    
    private lazy var pageControl: PageControl = {
        return PageControl(frame: .zero)
    }()
    
    /// PageControl 当前选中图标
    public var indicatorImage: UIImage? {
        didSet {
            pageControl.indicatorImage = indicatorImage
        }
    }

    /// PageControl 默认图标
    public var preferredIndicatorImage: UIImage? {
        didSet {
            pageControl.preferredIndicatorImage = preferredIndicatorImage
        }
    }
    
    /// PageControl item 间距
    public var itemSpacing = 2.5 {
        didSet {
            pageControl.itemSpacing = itemSpacing
        }
    }
    
    private lazy var pagePromptView: PagePromptView = {
        let pagePromptView = PagePromptView(frame: .zero)
        
        return pagePromptView
    }()
    
    /// 根据 pageControlStyle 设置 numberOfPages
    private var numberOfPages = 0 {
        didSet {
            if pageControlStyle == .dot {
                pageControl.numberOfPages = numberOfPages
            } else if pageControlStyle == .text {
                pagePromptView.numberOfPages = numberOfPages
            }
        }
    }
    
    /// 根据 pageControlStyle 设置 currentPage
    private var currentPage = 0 {
        didSet {
            if pageControlStyle == .dot {
                pageControl.currentPage = currentPage
            } else if pageControlStyle == .text {
                pagePromptView.currentPage = currentPage
            }
            
            var maxIndex = items.count - 1
            
            if supportCircularlyRolling, items.count > 1 {
                maxIndex -= 2
            }
            
            currentPageDidChangeHandler?(max(0, min(currentPage, maxIndex)))
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = backgroundColor
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?
    private var currentPageDidChangeHandler: ((_ index: Int) -> Void)?
    private var timer: Timer?
    
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
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        if let size = itemSize {
            layout.itemSize = size
        } else {
            layout.itemSize = CGSize(width: width - (sideItemSpacing * 4), height: height)
        }
        
        collectionView.frame = bounds
        
        if pageControlStyle == .dot {
            let size = pageControl.sizeForNumberOfPages()
            var x: CGFloat = 0
            
            switch pageControlAlignment {
            case .left:
                x = 10
            case .right:
                x = (width - size.width) - 10
            case .center:
                x = (width - size.width) / 2
            }
            
            pageControl.frame = CGRect(x: x, y: height - size.height - 8, width: min(size.width, width), height: size.height)
        } else if pageControlStyle == .text {
            pagePromptView.frame = CGRect(x: width - 75, y: height - 30, width: 56, height: 22)
        }
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - public method
    
    /// 设置数据后刷新视图
    @objc public func reloadData() {
        collectionView.reloadData {
            if self.items.count > 1 {
                if self.supportCircularlyRolling {
                    self.safetyScrollToItem(indexPath: IndexPath(item: 1, section: 0), animated: false)
                }
            }
            
            self.restartPlay()
        }
    }
    
    /// 点击 item 后触发
    @objc public func selectedItemHandler(_ selectedItemHandler: @escaping (_ index: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
    
    /// currentPage 改变后触发
    public func currentPageDidChangeHandler(_ currentPageDidChangeHandler: @escaping (_ index: Int) -> Void) {
        self.currentPageDidChangeHandler = currentPageDidChangeHandler
    }
    
    // MARK: - private method
    
    private func setupViews() {
        addSubview(collectionView)
        addSubview(pageControl)
    }
    
    private func restartPlay() {
        stopTimer() // 放到外面是因为有可能上次 items.count 和这次的不一样
        
        if autoRolling, items.count > 1 {
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: { [weak self] timer in
                self?.nextPage()
            })
        }
    }
    
    private func nextPage() {
        currentPage += 1
        
        if supportCircularlyRolling {
            safetyScrollToItem(indexPath: IndexPath(item: currentPage + 1, section: 0))
            
            if currentPage == (items.count - 2) {
                delay(0.25) {
                    self.currentPage = 0
                    self.safetyScrollToItem(indexPath: IndexPath(item: 1, section: 0), animated: false)
                }
            }
        } else {
            safetyScrollToItem(indexPath: IndexPath(item: currentPage, section: 0))
            
            if currentPage == (items.count - 1) {
                stopTimer()
            }
        }
    }
    
    func safetyScrollToItem(indexPath: IndexPath, animated: Bool = true) {
        guard indexPath.item <= (collectionView.numberOfItems(inSection: 0) - 1) else {
            return
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    /// 使用 CarouselFlowLayout
    private func useCarouselFlowLayout() {
        let layout = CarouselFlowLayout()
        layout.sideItemScale = sideItemScale
        layout.sideItemAlpha = sideItemAlpha
        layout.sideItemSpacing = sideItemSpacing
        
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = false
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - delegate method
    
extension BannerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfPages = (supportCircularlyRolling && items.count > 1) ? (items.count - 2) : items.count
        currentPage = 0
        
        setNeedsLayout()
        
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.reuseIdentifier, for: indexPath) as! BannerCell
        cell.contentView.cornerRadius = itemCornerRadius
        
        if let url = items[indexPath.item] as? String {
            cell.imageView.contentMode = .center
            cell.imageView.setImageURL(url, placeholder: placeholder) { [weak self] image in
                guard image != nil else {
                    return
                }

                cell.imageView.contentMode = self?.imageContentMode ?? .scaleAspectFill // 默认模式会破坏图片比例，目前保持图片比例不变，并且填充视图
            }
        } else if let image = items[indexPath.item] as? UIImage {
            cell.imageView.image = image
            cell.imageView.contentMode = imageContentMode
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItemHandler?(currentPage)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()// 开始拖动时停止自动滚动
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNo = Int(ceil(scrollView.contentOffset.x / ((scrollView.contentSize.width + (sideItemSpacing * CGFloat(items.count))) / CGFloat(items.count))))
        
        if supportCircularlyRolling {
            // 因为数据源比实际数据多2个，所以当滑动到第一页和最后一页时需要干预 currentPage 的值
            if pageNo == 0 {
                currentPage = items.count - 3
                safetyScrollToItem(indexPath: IndexPath(item: currentPage + 1, section: 0), animated: false)
            } else if pageNo == items.count - 1 {
                currentPage = 0
                safetyScrollToItem(indexPath: IndexPath(item: 1, section: 0), animated: false)
            } else {
                currentPage = pageNo - 1
            }
        } else {
            currentPage = pageNo
        }
        
        restartPlay() // 重新开始计时，避免刚拖动完，就因定时器触发后切换数据
    }
}

class PagePromptView: UIView {
    fileprivate var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        textLabel.textAlignment = .center
        
        return textLabel
    }()
    
    public var numberOfPages = 0 {
        didSet {
            textLabel.text = "\(currentPage + 1)/\(numberOfPages)"
        }
    }
    
    public var currentPage = 0 {
        didSet {
            textLabel.text = "\(currentPage + 1)/\(numberOfPages)"
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        cornerRadius = 10
        backgroundColor = UIColor(hex: 0x1D2736)?.withAlphaComponent(0.5)
        
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = bounds
        
        isHidden = (numberOfPages < 2)
    }
}
