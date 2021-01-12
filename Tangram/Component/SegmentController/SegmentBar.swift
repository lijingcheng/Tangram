//
//  SegmentBar.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 多 Tab 切换用的视图，用来展示标题，支持滑动
public class SegmentBar: UICollectionView {
    /// 设置当前 Tab 颜色
    public var selectedTintColor = UIColor(hex: 0x30333B)!
    
    /// 设置未选中 Tab 颜色
    public var unselectedTintColor = UIColor(hex: 0x9B9DA5)!
    
    /// 用来设置背景渐变色
    public var backgroundColors: [UIColor]?
    
    /// 是否隐藏 segmentBar 底下的线
    public var hiddenBottomLine = false {
        didSet {
            if hiddenBottomLine {
                barBottomLineLayer.removeFromSuperlayer()
            }
        }
    }
    
    /// 当前 Tab 的 scale
    public var selectedItemScale: CGFloat = 1.0
    
    /// 三种样式的 segmentBarItem 背景图，分别用于当前 item 为最左边和最右边以及在中间时的背景图片样式
    public var leftItemBackgroundImage: UIImage?
    public var centerItemBackgroundImage: UIImage?
    public var rightItemBackgroundImage: UIImage?
    
    /// 设置 Tab 宽
    public var itemWidth: CGFloat = 0.0
    
    /// 设置 Tab 下面的线的宽
    public var itemLineWidth: CGFloat = 70
    
    /// 设置当前 item 下短线条的颜色
    public var itemLineColor = UIColor(hex: 0x30333B)! {
        didSet {
            itemLineView.backgroundColor = itemLineColor
        }
    }
    
    lazy var itemLineView: UIView = {
        let itemLineView = UIView(frame: .zero)
        itemLineView.cornerRadius = 1.0
        itemLineView.backgroundColor = selectedTintColor
        
        return itemLineView
    }()
    
    var itemLineViewOriginX: CGFloat {
        return CGFloat(selectedIndex) * itemWidth + (itemWidth - itemLineWidth) / 2
    }
    
    lazy var selectedItemBackgroundImageView: UIImageView = {
        let selectedItemBackgroundImageView = UIImageView(frame: .zero)
        
        return selectedItemBackgroundImageView
    }()
    
    var itemBackgroundImageViewOriginX: CGFloat {
        return CGFloat(selectedIndex) * itemWidth
    }
    
    lazy var barBottomLineLayer: CALayer = {
        let barBottomLineLayer = CALayer()
        barBottomLineLayer.backgroundColor = UIColor(hex: 0xF3F4F5)?.cgColor
        
        return barBottomLineLayer
    }()
    
    /// 设置标题数组
    public var titles: [String]? {
        didSet {
            items = titles?.map({ (title) -> SegmentBarItem in
                SegmentBarItem(title)
            })
        }
    }
    
    /// 设置标题数组
    public var attributedTitles: [[SegmentBarItemState: NSAttributedString]]? {
        didSet {
            items = attributedTitles?.map({ attributedTitle -> SegmentBarItem in
                SegmentBarItem(attributedTitle: attributedTitle)
            })
        }
    }
    
    /// 设置 item 对象数组
    public var items: [SegmentBarItem]? {
        didSet {
            if itemWidth <= 0 {
                itemWidth = Device.width / CGFloat((items?.count)!)
            }
            
            DispatchQueue.main.async {
                self.reloadData {
                    guard let itemsCount = self.items?.count, self.selectedIndex < itemsCount, self.selectedIndex > 0 else { return }
                    
                    self.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: [], animated: false)
                    
                    self.segmentBarControllerScrollToItem(index: self.selectedIndex, animated: false)
                }
            }
        }
    }
    
    /// 设置当前选中 index
    public var selectedIndex: Int = 0 {
        willSet {
            if let items = self.items {
                if newValue < 0 || newValue >= items.count {
                    return
                }
            }
        }
        didSet {
            DispatchQueue.main.async {
                self.reloadData {
                    guard let itemsCount = self.items?.count, self.selectedIndex < itemsCount else {
                        return
                    }
                        
                    self.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: [], animated: true)
                    self.selectedItemHandler?(self.selectedIndex)

                    self.itemLineView.x = self.itemLineViewOriginX
                    self.selectedItemBackgroundImageView.x = self.itemBackgroundImageViewOriginX
                    
                    self.segmentBarControllerScrollToItem(index: self.selectedIndex, animated: true)
                }
            }
        }
    }

    /// segmentBar 如果要与 ViewController 联动则需要设置这个属性
    public weak var segmentBarController: SegmentBarController? {
        didSet {
            segmentBarController?.segmentBar = self
        }
    }
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?

    private var currentTask: Task?
    
    public init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        super.init(frame: frame, collectionViewLayout: flowLayout)
        
        configurationView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        collectionViewLayout = flowLayout
        
        configurationView()
    }
    
    private func configurationView() {
        backgroundColor = .white
        delegate = self
        dataSource = self
        bounces = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        addSubview(itemLineView)
        layer.addSublayer(barBottomLineLayer)
        backgroundView = selectedItemBackgroundImageView
        
        register(SegmentBarItemView.self, forCellWithReuseIdentifier: "segmentBarItemId")
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        } else {
            parentViewController?.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        barBottomLineLayer.frame = CGRect(x: 0, y: height - 0.5, width: max(Device.width, contentSize.width), height: 0.5)
        itemLineView.frame = CGRect(x: itemLineViewOriginX, y: height - 2, width: itemLineWidth, height: 2)
        selectedItemBackgroundImageView.frame = CGRect(x: itemBackgroundImageViewOriginX, y: 0, width: itemWidth, height: height)
        
        if selectedItemBackgroundImageView.x == 0 {
            selectedItemBackgroundImageView.image = leftItemBackgroundImage
        } else if selectedItemBackgroundImageView.x + itemWidth == width {
            selectedItemBackgroundImageView.image = rightItemBackgroundImage
        } else {
            selectedItemBackgroundImageView.image = centerItemBackgroundImage
        }
        
        if let colors = backgroundColors {
            applyGradient(colors, orientation: .vertical)
        }
    }

    public func segmentItemDidSelected(_ selectedItemHandler: @escaping (_ index: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
    
    public func segmentBarControllerDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.x > 0, (scrollView.contentOffset.x + scrollView.width) < scrollView.contentSize.width else {
            return
        }
        
        let progress = abs(scrollView.contentOffset.x - scrollView.width * CGFloat(selectedIndex)) / scrollView.width
        let isRightToLeft = scrollView.contentOffset.x > (CGFloat(selectedIndex) * scrollView.width)
        let nextCellIndex = max(0, min((items?.count)! - 1, isRightToLeft ? (selectedIndex + 1) : (selectedIndex - 1)))
        
        let currentScale: CGFloat = selectedItemScale - (selectedItemScale - 1) * progress
        let nextScale: CGFloat = 1 + (selectedItemScale - 1) * progress
        
        let currentCell = cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? SegmentBarItemView
        currentCell?.titleLabel.textColor = selectedTintColor.transform(unselectedTintColor, fraction: progress)
        currentCell?.titleLabel.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
        
        let nextCell = cellForItem(at: IndexPath(item: nextCellIndex, section: 0)) as? SegmentBarItemView
        nextCell?.titleLabel.textColor = unselectedTintColor.transform(selectedTintColor, fraction: progress)
        nextCell?.titleLabel.transform = CGAffineTransform(scaleX: nextScale, y: nextScale)
        
        if isRightToLeft {
            itemLineView.x = itemLineViewOriginX + itemWidth * progress
            selectedItemBackgroundImageView.x = itemBackgroundImageViewOriginX + itemWidth * progress
        } else {
            itemLineView.x = itemLineViewOriginX - itemWidth * progress
            selectedItemBackgroundImageView.x = itemBackgroundImageViewOriginX - itemWidth * progress
        }
    }
    
    fileprivate func segmentBarControllerScrollToItem(index: Int, animated: Bool = true) {
        if let segmentBarController = self.segmentBarController {
            // segmentBarController 的当前 index 如果和参数中 index 值不一样时再做切换
            if Int(abs(segmentBarController.collectionView.contentOffset.x / segmentBarController.collectionView.width)) != index {
                cancel(currentTask) // 快速点击切换 tab 时需要先 cancel，否则 segmentBarController.scrollViewDidScroll 会被触发
                
                segmentBarController.collectionView.delegate = nil
                segmentBarController.scrollToItem(index: index)
                currentTask = delay(0.5) {
                    segmentBarController.collectionView.delegate = segmentBarController
                }
            }
        }
    }
}

extension SegmentBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
 
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segmentBarItemId", for: indexPath) as! SegmentBarItemView
        cell.titleLabel.frame = CGRect(x: 0, y: 0, width: itemWidth, height: height)
        cell.titleLabel.textColor = (selectedIndex == indexPath.item) ? selectedTintColor : unselectedTintColor
        cell.titleLabel.transform = (selectedIndex == indexPath.item) ? CGAffineTransform(scaleX: selectedItemScale, y: selectedItemScale): .identity
        
        if let segmentBarItem = items?[indexPath.item] {
            if let attributedTitle = segmentBarItem.attributedTitle {
                if selectedIndex == indexPath.item, attributedTitle[.selected] != nil {
                    cell.titleLabel.attributedText = attributedTitle[.selected]
                } else {
                    cell.titleLabel.attributedText = attributedTitle[.normal]
                }
            } else {
                cell.titleLabel.text = segmentBarItem.title
            }
        }
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndex != indexPath.item else {
            return
        }

        selectedIndex = indexPath.item
    }
}
