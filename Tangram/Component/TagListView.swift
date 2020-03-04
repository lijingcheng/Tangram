//
//  TagListView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
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

@IBDesignable
public class TagListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBInspectable public var tagItemSpacing: CGFloat = 10.0 {
        didSet {
            let layout = collectionView.collectionViewLayout as? MultipleLinesFlowLayout
            layout?.minimumInteritemSpacing = tagItemSpacing
        }
    }
    
    @IBInspectable public var tagLineSpacing: CGFloat = 10.0 {
        didSet {
            let layout = collectionView.collectionViewLayout as? MultipleLinesFlowLayout
            layout?.minimumLineSpacing = tagLineSpacing
        }
    }

    public var tagCornerRadius: CGFloat = 10.0
    public var tagBorderWidth: CGFloat = 0.5
    public var tagContentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    public var tagBorderColor = UIColor.lightGray
    public var tagTextColor = UIColor.darkGray
    public var tagTextColors: [String: UIColor]? // 多 tag 文字颜色不同时设置这个参数，key 是要匹配的文字内容
    public var tagBackgroundColor = UIColor.white
    
    /// 默认仅支持一行，如果需要多行展示，可以设置为 0 （目前仅支持 1 和 0）
    public var numberOfLines = 1
    
    public var supportSelected = false
    public var supportMultipleSelected = false
    public var tagSelectedBorderColor: UIColor = UIColor.orange
    public var tagSelectedTextColor: UIColor = UIColor.orange
    public var tagSelectedBackgroundColor: UIColor = UIColor.white
    
    public var tagFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            testLabel.font = tagFont
        }
    }

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
        collectionView.backgroundColor = tagBackgroundColor
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
            itemSizes.removeAll()
            
            datas.forEach { item in
                itemSizes.append(getTagItemSize(item))
            }
            
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

    override public func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(collectionView)
    }
 
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        if numberOfLines == 1 {
            tagLineSpacing = 10000
        }
    }
    
    /// 刷新数据
    public func reloadData() {
        selectedDatasIndex.removeAll()
        
        collectionView.reloadData()
    }
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?
    
    public func selectedItemHandler(_ selectedItemHandler: @escaping (_ indexs: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
}

extension TagListView {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getTagItemSize(datas[indexPath.item])
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
            cell.titleLabel.textColor = tagTextColor
            cell.borderColor = tagBorderColor
            cell.layer.backgroundColor = tagBackgroundColor.cgColor
        }
        
        tagTextColors?.forEach({ (key, value) in
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

extension TagListView {
    /// 返回 tagListView 需要占用的高度
    public func contentHeight() -> CGFloat {
        guard numberOfLines == 0 else {
            return collectionView.height
        }
        
        var contentHeight: CGFloat = 0
 
        var originX: CGFloat = 0
        var originY: CGFloat = 0

        for index in 0..<itemSizes.count {
            let itemSize = itemSizes[index]
                  
            if index == 0 {
                contentHeight += itemSize.height
            }
                         
            if (originX + itemSize.width) > collectionView.width {
                originX = 0
                originY += (tagLineSpacing + itemSize.height)
                contentHeight += (tagLineSpacing + itemSize.height)
            }
                         
            originX += (tagItemSpacing + itemSize.width)
        }
              
        return contentHeight
    }
    
    /// 根据内容计算 tag size
    private func getTagItemSize(_ text: String) -> CGSize {
        testLabel.text = text
        testLabel.sizeToFit()
        
        let itemWidth = min(width, ceil(testLabel.width) + tagContentInset.left + tagContentInset.right)
        let itemHeight = ceil(testLabel.height) + tagContentInset.top + tagContentInset.bottom
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
