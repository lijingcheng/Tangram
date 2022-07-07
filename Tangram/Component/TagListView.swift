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
    
    var leftButton: UIButton = {
        return UIButton(frame: .zero)
    }()
    
    var rightButton: UIButton = {
        return UIButton(frame: .zero)
    }()
    
    var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    /// 标签文字左右图片对象、居左或居右的间距和对应点击事件
    var leftImageLeading: CGFloat = 0
    var leftImageTapHandler: ((_ index: Int) -> Void)?
    var rightImageTrailing: CGFloat = 0
    var rightImageTapHandler: ((_ index: Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        layer.masksToBounds = true
        
        leftButton.addTarget(self, action: #selector(TagCell.leftButtonAction(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(TagCell.rightButtonAction(_:)), for: .touchUpInside)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let size = leftButton.imageView?.image?.size {
            leftButton.frame = CGRect(x: leftImageLeading, y: (height - size.height) / 2, width: size.width, height: size.height)
        }
        
        if let size = rightButton.imageView?.image?.size {
            rightButton.frame = CGRect(x: width - size.width - rightImageTrailing, y: (height - size.height) / 2, width: size.width, height: size.height)
        }
        
        titleLabel.frame = CGRect(x: contentInset.left, y: contentInset.top, width: width - contentInset.left - contentInset.right, height: height - contentInset.top - contentInset.bottom)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        leftButton.setImage(nil, for: .normal)
        rightButton.setImage(nil, for: .normal)
    }
    
    @objc private func leftButtonAction(_ sender: UIButton) {
        leftImageTapHandler?(tag)
    }
    
    @objc private func rightButtonAction(_ sender: UIButton) {
        rightImageTapHandler?(tag)
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
    public var numberOfLines = 1 {
        didSet {
            resetCollectionViewLayout()
        }
    }
    
    /// 是否支持横向滚动，只有当 numberOfLines = 1 时才有作用
    public var supportHorizontalScroll = false {
        didSet {
            resetCollectionViewLayout()
        }
    }
     
    /// 是否支持选择，默认单选
    public var supportSelected = false
    
    /// 是否支持反向选择（默认不支持反向选择，当控件支持多选时默认支持反向选择，如不需要可以设置为 false）
    public var supportReverseSelected = false
     
    /// 在支持选择标签的情况下，可以进一步设置是否可以多选，默认只能单选
    public var supportMultipleSelected = false {
        didSet {
            supportReverseSelected = supportMultipleSelected
        }
    }
     
    public var tagSelectedBorderColor: UIColor = UIColor(hex: 0x004696)!
    public var tagSelectedTextColor: UIColor = UIColor(hex: 0x004696)!
    public var tagSelectedBackgroundColor: UIColor = UIColor.white
    
    /// 需要调整标签大小时，要设置此属性，根据设计稿中标签边框和内部文字的上下左右边距来调整，如果文字两边要显示图片，inset 的值要算上图片的宽度和间距
    public var tagContentInset = UIEdgeInsets(top: 1.5, left: 4, bottom: 1.5, right: 4)
    
    /// 这是整个 tagListView 视图的 contentInset，控制所有标签整体和 tagListView 的 contentInset
    public var contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            collectionView.contentInset = contentInset
        }
    }
    
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
    
    /// 标签文字左右图片对象、居左或居右的间距和对应点击事件
    private var leftImage: UIImage?
    private var leftImageLeading: CGFloat = 0
    private var leftImageTapHandler: ((_ index: Int) -> Void)?
    private var rightImage: UIImage?
    private var rightImageTrailing: CGFloat = 0
    private var rightImageTapHandler: ((_ index: Int) -> Void)?
    
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
        collectionView.contentInset = contentInset
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
    
    /// 用来记录所有数据的 size，通过计算文字多少得出来的
    private var itemSizes: [CGSize] = []
    
    /// 指定 tag 固定宽度，设置这个属性后就不要设置 tagContentInset 了
    public var tagItemSize: CGSize? {
        didSet {
            tagContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }

    /// 选中数据的 index
    public var selectedDatasIndex: [Int] = [] {
        didSet {
            reloadData()
        }
    }
    
    /// 控件大小监听器
    private var observeFrame: NSKeyValueObservation?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
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
        itemSizes.removeAll()
        
        datas.forEach { item in
            if let itemSize = tagItemSize {
                itemSizes.append(itemSize)
            } else {
                itemSizes.append(TagListView.getTagItemSize(item, maxWidth: width - contentInset.left - contentInset.right, tagContentInset: tagContentInset, useLabel: testLabel))
            }
        }
        
        collectionView.reloadData()
    }
    
    /// 支持选择的情况下，每次点击标签都会把当前点击标签的 index 返回，如果要拿已选中的所有标签的 indexs，请使用 selectedDatasIndex 属性
    public func selectedItemHandler(_ selectedItemHandler: @escaping (_ indexs: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
    
    /// 点击文字左边小图标后响应事件并回传 index，leading 为图标居左距离
    public func leftImageTapHandler(image: UIImage?, leading: CGFloat, _ tapHandler: @escaping (_ index: Int) -> Void) {
        self.leftImage = image
        self.leftImageLeading = leading
        self.leftImageTapHandler = tapHandler
    }
    
    /// 点击文字右边小图标后响应事件并回传 index，trailing 为图标居右距离，如果做的是“删除”操作，需要重新设置数据源并 reload
    public func rightImageTapHandler(image: UIImage?, trailing: CGFloat, _ tapHandler: @escaping (_ index: Int) -> Void) {
        self.rightImage = image
        self.rightImageTrailing = trailing
        self.rightImageTapHandler = tapHandler
    }
    
    private func setupView() {
        isUserInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        addSubview(collectionView)
        
        observeFrame = collectionView.observe(\.frame) { [weak self] (collectionView, change) in
            self?.reloadData()
        }
    }
    
    private func resetCollectionViewLayout() {
        if numberOfLines == 1, supportHorizontalScroll {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = tagLineSpacing
            layout.minimumInteritemSpacing = tagItemSpacing
            
            collectionView.collectionViewLayout = layout
            collectionView.isScrollEnabled = true
        } else {
            let layout = MultipleLinesFlowLayout()
            layout.delegate = self
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = tagLineSpacing
            layout.minimumInteritemSpacing = tagItemSpacing
            
            collectionView.collectionViewLayout = layout
            collectionView.isScrollEnabled = false
        }
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
        cell.tag = indexPath.item
        
        if supportSelected && selectedDatasIndex.contains(indexPath.item) {
            cell.titleLabel.textColor = tagSelectedTextColor
            cell.borderColor = tagSelectedBorderColor
            cell.layer.backgroundColor = tagSelectedBackgroundColor.cgColor
        } else {
            cell.titleLabel.textColor = textColor != nil ? textColor : UIColor(hex: 0x8898C2)
            cell.borderColor = tagBorderColor != nil ? tagBorderColor : UIColor(hex: 0x8898C2)
            cell.layer.backgroundColor = tagBackgoundColor != nil ? tagBackgoundColor?.cgColor : UIColor.white.cgColor
        }
        
        if let leftImage = self.leftImage {
            cell.leftButton.setImage(leftImage, for: .normal)
            cell.leftImageLeading = leftImageLeading
            cell.leftImageTapHandler = leftImageTapHandler
        }
        
        if let rightImage = self.rightImage {
            cell.rightButton.setImage(rightImage, for: .normal)
            cell.rightImageTrailing = rightImageTrailing
            cell.rightImageTapHandler = rightImageTapHandler
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
                if selectedDatasIndex.contains(indexPath.item) {
                    if supportReverseSelected {
                        selectedDatasIndex.remove(indexPath.item)
                    }
                } else {
                    selectedDatasIndex.append(indexPath.item)
                }
            } else {
                if selectedDatasIndex.contains(indexPath.item) {
                    if supportReverseSelected {
                        selectedDatasIndex.remove(indexPath.item)
                    }
                } else {
                    selectedDatasIndex = [indexPath.item]
                }
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
    var tagContentInset: UIEdgeInsets
    var font: UIFont
    
    public init(estimatedSize: CGSize, itemSpacing: CGFloat, lineSpacing: CGFloat, contentInset: UIEdgeInsets = .zero, tagContentInset: UIEdgeInsets, font: UIFont) {
        self.estimatedSize = estimatedSize
        self.itemSpacing = itemSpacing
        self.lineSpacing = lineSpacing
        self.contentInset = contentInset
        self.tagContentInset = tagContentInset
        self.font = font
    }
}

extension TagListView {
    /// 通过指定相关数据来计算 tagListView 需要占用的高度
    public static func contentHeight(_ datas: [String], style: TagStyle, tagItemSize: CGSize = .zero) -> CGFloat {
        var sizes: [CGSize] = []
        
        let useLabel = UILabel(frame: .zero)
        useLabel.font = style.font
        
        datas.forEach { item in
            if tagItemSize != .zero {
                sizes.append(tagItemSize)
            } else {
                sizes.append(TagListView.getTagItemSize(item, maxWidth: style.estimatedSize.width, tagContentInset: style.tagContentInset, useLabel: useLabel))
            }
        }
        
        return TagListView.calculateContentHeight(style.estimatedSize, itemSpacing: style.itemSpacing, lineSpacing: style.lineSpacing, contentInset: style.contentInset, itemSizes: sizes)
    }
    
    /// 通过 tagListView 对象计算它需要占用的高度，要注意调用时机
    public func contentHeight() -> CGFloat {
        return TagListView.calculateContentHeight(collectionView.size, itemSpacing: tagItemSpacing, lineSpacing: tagLineSpacing, contentInset: collectionView.contentInset, itemSizes: itemSizes)
    }
    
    /// 计算 tagListView 需要占用的高度
    private static func calculateContentHeight(_ estimatedSize: CGSize, itemSpacing: CGFloat, lineSpacing: CGFloat, contentInset: UIEdgeInsets, itemSizes: [CGSize]) -> CGFloat {
        var contentHeight: CGFloat = contentInset.top
        
        var originX: CGFloat = contentInset.left
        var originY: CGFloat = contentInset.top
               
        for index in 0..<itemSizes.count {
            let itemSize = itemSizes[index]
                         
            if index == 0 {
                contentHeight += itemSize.height
            }
            
            if (originX + itemSize.width + contentInset.right) > estimatedSize.width {
                originX = contentInset.left
                originY += (lineSpacing + itemSize.height)
                contentHeight += (lineSpacing + itemSize.height)
            }
            
            originX += (itemSpacing + itemSize.width)
        }
        
        contentHeight += contentInset.bottom
        
        return contentHeight
    }
    
    /// 根据内容计算 tag size
    private static func getTagItemSize(_ text: String, maxWidth: CGFloat, tagContentInset: UIEdgeInsets, useLabel: UILabel) -> CGSize {
        useLabel.text = text
        useLabel.sizeToFit()
        
        let itemWidth = min(maxWidth, ceil(useLabel.width) + tagContentInset.left + tagContentInset.right)
        let itemHeight = ceil(useLabel.height) + tagContentInset.top + tagContentInset.bottom
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
