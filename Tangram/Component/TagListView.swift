//
//  TagListView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 展示多个小标签视图，支持换行和选择
class TagCell: UICollectionViewCell {
    static let reuseIdentifier = "tagListViewItemId"
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.masksToBounds = true
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.masksToBounds = true
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = CGRect(x: contentInset.left, y: contentInset.top, width: width - contentInset.left - contentInset.right, height: height - contentInset.top - contentInset.bottom)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
    }
}

public class TagListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBInspectable public var fontSize: CGFloat = 0.0 {
        didSet {
            tagFont = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    @IBInspectable public var tagSpacing: CGFloat = 0.0 {
        didSet {
            tagItemSpacing = tagSpacing
            tagLineSpacing = tagSpacing
        }
    }
    
    @IBInspectable public var tagCornerRadius: CGFloat = 2.5
    @IBInspectable public var tagBorderWidth: CGFloat = 0.5
    @IBInspectable public var tagBorderColor: UIColor?
    @IBInspectable public var textColor: UIColor?
    @IBInspectable public var tagBackgoundColor: UIColor?
    
    /// 默认仅支持一行，如果需要多行展示，可以设置为 0 （目前仅支持 1 和 0）
    public var numberOfLines = 1
     
    /// 是否支持选择，默认单选
    public var supportSelected = false
     
    /// 在支持选择标签的情况下，可以进一步设置是否可以多选，默认只能单选
    public var supportMultipleSelected = false
     
    public var tagSelectedBorderColor: UIColor = UIColor(hex: 0xDBB177)!
    public var tagSelectedTextColor: UIColor = UIColor(hex: 0xDBB177)!
    public var tagSelectedBackgroundColor: UIColor = UIColor.white
    
    /// 需要调整标签大小时，要设置此属性，根据设计稿中标签边框和内部文字的上下左右边距来调整
    public var tagContentInset = UIEdgeInsets(top: 1.5, left: 4, bottom: 1.5, right: 4)
    
    public var textColors: [String: UIColor]? // 多 tag 文字颜色不同时设置这个参数，key 是要匹配的文字内容
     
    public var tagItemSpacing: CGFloat = 3.0 {
        didSet {
            let layout = collectionView.collectionViewLayout as? MultipleLinesFlowLayout
            layout?.minimumInteritemSpacing = tagItemSpacing
        }
    }
    
    public var tagLineSpacing: CGFloat = 2.0 {
        didSet {
            let layout = collectionView.collectionViewLayout as? MultipleLinesFlowLayout
            layout?.minimumLineSpacing = tagLineSpacing
        }
    }
    
    public var tagFont = UIFont.systemFont(ofSize: 14, weight: .regular) {
        didSet {
            testLabel.font = tagFont
        }
    }
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?

    public lazy var collectionView: UICollectionView = {
        let layout = MultipleLinesFlowLayout()
        layout.delegate = self
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = tagLineSpacing
        layout.minimumInteritemSpacing = tagItemSpacing
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isUserInteractionEnabled = false
        collectionView.register(TagCell.self, forCellWithReuseIdentifier: TagCell.reuseIdentifier)
        
        return collectionView
    }()
    
    /// 用于计算 tag 宽度
    private lazy var testLabel: UILabel = {
        let testLabel = UILabel(frame: .zero)
        testLabel.font = tagFont
        
        return testLabel
    }()

    /// 标签列表内容
    public var datas: [String] = [] {
        didSet {
            reloadData()
        }
    }
    
    /// 用来记录所有数据的 size
    private var itemSizes: [CGSize] = []
    
    /// 选中的数据
    public var selectedDatas: [String] = [] {
        didSet {
            reloadData()
        }
    }

    /// 选中数据的 index
    public var selectedDatasIndex: [Int] = []
    
    /// 控件大小监听器
    private var observeFrame: NSKeyValueObservation?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        addSubview(collectionView)
        
        observeFrame = collectionView.observe(\.frame) { [weak self] (collectionView, change) in
            self?.reloadData()
        }
    }
 
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        if numberOfLines == 1 {
            tagLineSpacing = 10000
        }
    }
    
    deinit {
        observeFrame?.invalidate()
    }
    
    /// 刷新数据
    public func reloadData() {
        selectedDatasIndex.removeAll()
        itemSizes.removeAll()
        
        datas.forEach { item in
            itemSizes.append(TagListView.getTagItemSize(item, maxWidth: width, contentInset: tagContentInset, useLabel: testLabel))
        }
        
        collectionView.reloadData()
    }
    
    /// 支持选择的情况下，每次点击标签都会把当前点击标签的 index 返回，如果要拿已选中的所有标签的 indexs，请使用 selectedDatasIndex 属性
    public func selectedItemHandler(_ selectedItemHandler: @escaping (_ indexs: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
}

extension TagListView {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSizes[indexPath.item]
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.reuseIdentifier, for: indexPath) as! TagCell
        cell.titleLabel.text = datas[indexPath.item]
        cell.titleLabel.font = tagFont
        cell.contentInset = tagContentInset
        cell.cornerRadius = tagCornerRadius
        cell.borderWidth = tagBorderWidth
        
        if supportSelected && selectedDatas.contains(datas[indexPath.item]) {
            cell.titleLabel.textColor = tagSelectedTextColor
            cell.borderColor = tagSelectedBorderColor
            cell.layer.backgroundColor = tagSelectedBackgroundColor.cgColor
            
            selectedDatasIndex.append(indexPath.item)
        } else {
            cell.titleLabel.textColor = textColor != nil ? textColor : UIColor(hex: 0x8898C2)
            cell.borderColor = tagBorderColor != nil ? tagBorderColor : UIColor(hex: 0x8898C2)
            cell.layer.backgroundColor = tagBackgoundColor != nil ? tagBackgoundColor?.cgColor : UIColor.white.cgColor
        }
        
        textColors?.forEach({ (key, value) in
            if key == datas[indexPath.item] {
                cell.titleLabel.textColor = value
                cell.borderColor = value
            }
        })
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if supportSelected {
            if supportMultipleSelected {
                if selectedDatas.contains(datas[indexPath.item]) {
                    selectedDatas.remove(datas[indexPath.item])
                } else {
                    selectedDatas.append(datas[indexPath.item])
                }
            } else {
                selectedDatas = [datas[indexPath.item]]
            }
            
            reloadData()
            
            selectedItemHandler?(indexPath.item)
        }
    }
}

public struct TagStyle {
    var estimatedSize: CGSize
    var itemSpacing: CGFloat
    var lineSpacing: CGFloat
    var contentInset: UIEdgeInsets
    var font: UIFont
    
    public init(estimatedSize: CGSize, itemSpacing: CGFloat, lineSpacing: CGFloat, contentInset: UIEdgeInsets, font: UIFont) {
        self.estimatedSize = estimatedSize
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        self.contentInset = contentInset
        self.font = font
    }
}

extension TagListView {
    /// 通过指定相关数据来计算 tagListView 需要占用的高度
    public static func contentHeight(_ datas: [String], style: TagStyle) -> CGFloat {
        var sizes: [CGSize] = []
        
        let useLabel = UILabel(frame: .zero)
        useLabel.font = style.font
        
        datas.forEach { item in
            sizes.append(TagListView.getTagItemSize(item, maxWidth: style.estimatedSize.width, contentInset: style.contentInset, useLabel: useLabel))
        }
        
        return TagListView.calculateContentHeight(style.estimatedSize, itemSpacing: style.itemSpacing, lineSpacing: style.lineSpacing, itemSizes: sizes)
    }
    
    /// 通过 tagListView 对象计算它需要占用的高度，要注意调用时机
    public func contentHeight() -> CGFloat {
        return TagListView.calculateContentHeight(collectionView.size, itemSpacing: tagItemSpacing, lineSpacing: tagLineSpacing, itemSizes: itemSizes)
    }
    
    /// 计算 tagListView 需要占用的高度
    private static func calculateContentHeight(_ estimatedSize: CGSize, itemSpacing: CGFloat, lineSpacing: CGFloat, itemSizes: [CGSize]) -> CGFloat {
        var contentHeight: CGFloat = 0
        
        var originX: CGFloat = 0
        var originY: CGFloat = 0
               
        for index in 0..<itemSizes.count {
            let itemSize = itemSizes[index]
                         
            if index == 0 {
                contentHeight += itemSize.height
            }
                                
            if (originX + itemSize.width) > estimatedSize.width {
                originX = 0
                originY += (lineSpacing + itemSize.height)
                contentHeight += (lineSpacing + itemSize.height)
            }
                                
            originX += (itemSpacing + itemSize.width)
        }
               
        return contentHeight
    }
    
    /// 根据内容计算 tag size
    private static func getTagItemSize(_ text: String, maxWidth: CGFloat, contentInset: UIEdgeInsets, useLabel: UILabel) -> CGSize {
        useLabel.text = text
        useLabel.sizeToFit()
        
        let itemWidth = min(maxWidth, ceil(useLabel.width) + contentInset.left + contentInset.right)
        let itemHeight = ceil(useLabel.height) + contentInset.top + contentInset.bottom
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
