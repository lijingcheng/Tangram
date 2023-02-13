//
//  SegmentBar.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

public struct SegmentBarAppearance {
    /// 设置当前 item 文字字体（目前仅支持 weight 和 unselectedTextFont 不一样，size 通过 selectedItemScale 来控制效果）
    public var selectedTextFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /// 设置未选中 item 文字字体
    public var unselectedTextFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    
    /// 设置当前 item 文字颜色
    public var selectedTintColor = UIColor(hex: 0x30333B)!
    
    /// 设置未选中 item 文字颜色
    public var unselectedTintColor = UIColor(hex: 0x9B9DA5)!
    
    /// 是否隐藏 segmentBar 底下的线
    public var hiddenBottomLine = false
    
    /// 是否隐藏 item 底下的线
    public var hiddenItemLine = false
    
    /// 设置 item 下面的线的宽
    public var itemLineWidth: CGFloat = 70
    
    /// 设置 item 下面的线的高
    public var itemLineHeight: CGFloat = 2
    
    /// 设置当前 item 下短线条的颜色
    public var itemLineColor = UIColor(hex: 0x30333B)!
    
    public init(selectedTextFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular), unselectedTextFont: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular), selectedTintColor: UIColor = UIColor(hex: 0x30333B)!, unselectedTintColor: UIColor = UIColor(hex: 0x9B9DA5)!, hiddenBottomLine: Bool = false, hiddenItemLine: Bool = false, itemLineWidth: CGFloat = 70, itemLineHeight: CGFloat = 2, itemLineColor: UIColor = UIColor(hex: 0x30333B)!) {
        self.selectedTextFont = selectedTextFont
        self.unselectedTextFont = unselectedTextFont
        self.selectedTintColor = selectedTintColor
        self.unselectedTintColor = unselectedTintColor
        self.hiddenBottomLine = hiddenBottomLine
        self.hiddenItemLine = hiddenItemLine
        self.itemLineWidth = itemLineWidth
        self.itemLineHeight = itemLineHeight
        self.itemLineColor = itemLineColor
    }
}

/// 多 Tab 切换用的视图，用来展示标题，支持滑动
public class SegmentBar: UIView {
    /// 设置 app 样式
    public static var appearance = SegmentBarAppearance()
    
    /// 设置当前 item 文字字体（目前仅支持 weight 和 unselectedTextFont 不一样，size 通过 selectedItemScale 来控制效果）
    public var selectedTextFont: UIFont?
    
    /// 设置未选中 item 文字字体
    public var unselectedTextFont: UIFont?

    /// 设置当前 item 文字颜色
    public var selectedTintColor: UIColor?
    
    /// 设置未选中 item 文字颜色
    public var unselectedTintColor: UIColor?
    
    /// 设置当前 item 下短线条的颜色
    public var itemLineColor: UIColor?
    
    /// 用来设置背景渐变色
    public var backgroundColors: [UIColor]?
    
    /// 是否隐藏 segmentBar 底下的线
    public var hiddenBottomLine: Bool?
    
    /// 是否隐藏 item 底下的线
    public var hiddenItemLine: Bool?
    
    /// 是否隐藏最右侧的渐变蒙层（设置为 false 并且 contentSize.width > width  时才会显示）
    public var hiddenHasMoreLayer = true
    
    /// 是否根据 item 文字多少来自动计算 itemWidth
    public var autoCalculationItemWidth = false
    
    /// autoCalculationItemWidth = true 时会使用此属性，itemWidth = 文字宽度 + itemSpacing
    public var itemSpacing: CGFloat = 20
    
    /// 当前 item 的 scale，当前 item 需要字体变大时通过这个属性来调整
    public var selectedItemScale: CGFloat = 1.0
    
    /// 设置 item 宽，不设置的话用 bar.width / items.count 来计算
    public var itemWidth: CGFloat?
    
    /// 设置 item 下面的线的宽
    public var itemLineWidth: CGFloat?
    
    /// 设置 item 下面的线的高
    public var itemLineHeight: CGFloat?
    
    /// 设置 item 下面的线离左边的距离
    public var itemLineOffsetX: CGFloat?
    
    /// 三种样式的 segmentBarItem 背景图，分别用于当前 item 为最左边和最右边以及在中间时的背景图片样式
    public var leftItemBackgroundImage: UIImage?
    public var centerItemBackgroundImage: UIImage?
    public var rightItemBackgroundImage: UIImage?
    
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
            itemWidths.removeAll()
            items?.forEach({ item in
                if let attributedTitle = item.attributedTitle, let title = attributedTitle[.normal] {
                    testLabel.attributedText = title
                } else {
                    testLabel.text = item.title
                }
                testLabel.sizeToFit()
        
                itemWidths.append(testLabel.width)
            })
            
            DispatchQueue.main.async {
                self.collectionView.reloadData {
                    guard let itemsCount = self.items?.count, self.selectedIndex < itemsCount, self.selectedIndex > 0 else { return }
                    
                    self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: [], animated: false)
                    
                    self.segmentBarControllerScrollToItem(index: self.selectedIndex, animated: false)
                }
            }
        }
    }
    
    lazy var itemLineView: UIView? = {
        return UIView(frame: .zero)
    }()
    
    var itemLineViewOriginX: CGFloat {
        if hiddenItemLine ?? SegmentBar.appearance.hiddenItemLine {
            return 0
        } else {
            let itemWidth = widthForItemAt(selectedIndex)
            
            var frontCellWidths = CGFloat(selectedIndex) * itemWidth
            
            if autoCalculationItemWidth {
                frontCellWidths = 0
                for i in 0..<itemWidths.count where i < selectedIndex {
                    frontCellWidths += (itemWidths[i] + itemSpacing)
                }
            }
            
            if let offsetX = itemLineOffsetX {
                return frontCellWidths + offsetX
            } else {
                return frontCellWidths + (itemWidth - (itemLineWidth ?? SegmentBar.appearance.itemLineWidth)) / 2
            }
        }
    }
    
    lazy var selectedItemBackgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.zPosition = -1
        
        return imageView
    }()
    
    var itemBackgroundImageViewOriginX: CGFloat {
        return CGFloat(selectedIndex) * widthForItemAt(selectedIndex)
    }
    
    lazy var barBottomLineLayer: CALayer? = {
        let barBottomLineLayer = CALayer()
        barBottomLineLayer.backgroundColor = UIColor(hex: 0xF3F4F5)?.cgColor
        
        return barBottomLineLayer
    }()
    
    lazy var hasMoreGradientLayer: CALayer? = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 255 / 255.0, green: 251 / 255.0, blue: 253 / 255.0, alpha: 1).cgColor, UIColor(red: 245 / 255.0, green: 247 / 255.0, blue: 249 / 255.0, alpha: 0).cgColor ]
        gradientLayer.startPoint = CGPoint(x: 0.93, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.locations = [0, 1]
        
        return gradientLayer
    }()
    
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
                self.collectionView.reloadData {
                    guard let itemsCount = self.items?.count, self.selectedIndex < itemsCount else {
                        return
                    }
                        
                    self.collectionView.scrollToItem(at: IndexPath(item: self.selectedIndex, section: 0), at: [], animated: true)

                    self.itemLineView?.x = self.itemLineViewOriginX
                    
                    self.selectedItemBackgroundImageView.x = self.itemBackgroundImageViewOriginX
                    
                    self.segmentBarControllerScrollToItem(index: self.selectedIndex, animated: true)
                    
                    self.selectedItemHandler?(self.selectedIndex)
                    
                    self.setNeedsLayout()
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
    
    /// 用于计算 item 宽度
    private lazy var testLabel: UILabel = {
        return UILabel(frame: .zero)
    }()
    
    /// 用来记录所有数据的 width
    private var itemWidths: [CGFloat] = []
    
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.insertSubview(selectedItemBackgroundImageView, at: 0)
        collectionView.register(SegmentBarItemView.self, forCellWithReuseIdentifier: "segmentBarItemId")
        
        return collectionView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configurationView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configurationView()
    }
    
    private func configurationView() {
        backgroundColor = .white

        addSubview(collectionView)
        
        if let itemLineView = itemLineView {
            collectionView.addSubview(itemLineView)
        }
        
        if let bottomLineLayer = barBottomLineLayer {
            collectionView.layer.addSublayer(bottomLineLayer)
        }
        
        if let hasMoreGradientLayer = hasMoreGradientLayer {
            layer.addSublayer(hasMoreGradientLayer)
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = self.bounds
        
        if hiddenBottomLine ?? SegmentBar.appearance.hiddenBottomLine {
            barBottomLineLayer?.frame = .zero
        } else {
            barBottomLineLayer?.frame = CGRect(x: 0, y: height - 0.5, width: max(Device.width, collectionView.contentSize.width), height: 0.5)
        }
        
        if hiddenItemLine ?? SegmentBar.appearance.hiddenItemLine {
            itemLineView?.frame = .zero
        } else {
            itemLineView?.backgroundColor = itemLineColor ?? SegmentBar.appearance.itemLineColor
            itemLineView?.cornerRadius = (itemLineHeight ?? SegmentBar.appearance.itemLineHeight) / 2
            itemLineView?.frame = CGRect(x: itemLineViewOriginX, y: height - (itemLineHeight ?? SegmentBar.appearance.itemLineHeight), width: itemLineWidth ?? SegmentBar.appearance.itemLineWidth, height: itemLineHeight ?? SegmentBar.appearance.itemLineHeight)
        }
        
        if !hiddenHasMoreLayer && collectionView.contentSize.width > width {
            hasMoreGradientLayer?.frame = CGRect(x: width - height, y: 0, width: height, height: height)
        } else {
            hasMoreGradientLayer?.frame = .zero
        }
        
        let itemWidth = widthForItemAt(selectedIndex)
        
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
}

extension SegmentBar {
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
        
        let selectedTintColor = selectedTintColor ?? SegmentBar.appearance.selectedTintColor
        let unselectedTintColor = unselectedTintColor ?? SegmentBar.appearance.unselectedTintColor
        
        let currentCell = collectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? SegmentBarItemView
        currentCell?.titleLabel.textColor = selectedTintColor.transform(unselectedTintColor, fraction: progress)
        currentCell?.titleLabel.transform = CGAffineTransform(scaleX: currentScale, y: currentScale)
        
        let nextCell = collectionView.cellForItem(at: IndexPath(item: nextCellIndex, section: 0)) as? SegmentBarItemView
        nextCell?.titleLabel.textColor = unselectedTintColor.transform(selectedTintColor, fraction: progress)
        nextCell?.titleLabel.transform = CGAffineTransform(scaleX: nextScale, y: nextScale)
        
        let itemWidth = widthForItemAt(selectedIndex)
        
        if isRightToLeft {
            itemLineView?.x = itemLineViewOriginX + itemWidth * progress
            selectedItemBackgroundImageView.x = itemBackgroundImageViewOriginX + itemWidth * progress
        } else {
            itemLineView?.x = itemLineViewOriginX - itemWidth * progress
            selectedItemBackgroundImageView.x = itemBackgroundImageViewOriginX - itemWidth * progress
        }
    }
    
    fileprivate func segmentBarControllerScrollToItem(index: Int, animated: Bool = true) {
        if let segmentBarController = self.segmentBarController {
            // segmentBarController 的当前 index 如果和参数中 index 值不一样时再做切换
            if Int(abs(segmentBarController.collectionView.contentOffset.x / segmentBarController.collectionView.width)) != index {
                segmentBarController.scrollToItem(index: index, animated: animated)
            }
        }
    }
    
    fileprivate func widthForItemAt(_ index: Int) -> CGFloat {
        if autoCalculationItemWidth {
            return itemWidths[index] + itemSpacing
        } else {
            if let items = items, !items.isEmpty {
                return itemWidth ?? (width / CGFloat(items.count))
            } else {
                return itemWidth ?? 0
            }
        }
    }
}

extension SegmentBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
 
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthForItemAt(indexPath.item), height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segmentBarItemId", for: indexPath) as! SegmentBarItemView
        cell.titleLabel.frame = CGRect(x: 0, y: 0, width: widthForItemAt(indexPath.item), height: height)
        cell.titleLabel.font = (selectedIndex == indexPath.item) ? (selectedTextFont ?? SegmentBar.appearance.selectedTextFont) : (unselectedTextFont ?? SegmentBar.appearance.unselectedTextFont)
        cell.titleLabel.transform = (selectedIndex == indexPath.item) ? CGAffineTransform(scaleX: selectedItemScale, y: selectedItemScale) : .identity
        cell.titleLabel.textColor = (selectedIndex == indexPath.item) ? (selectedTintColor ?? SegmentBar.appearance.selectedTintColor) : (unselectedTintColor ?? SegmentBar.appearance.unselectedTintColor)
        
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
            
            cell.iconImageView.image = segmentBarItem.image
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
