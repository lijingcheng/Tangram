//
//  SegmentControl.swift
//  Tangram
//
//  Created by 李京城 on 2021/1/12.
//  Copyright © 2021 李京城. All rights reserved.
//

import UIKit

/// 自定义 SegmentControl
public class SegmentControl: UICollectionView {
    /// 设置当前 Item 文字字体
    public var selectedTextFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    
    /// 设置未选中 Item 文字字体
    public var unselectedTextFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    /// 设置当前 Item 文字颜色
    public var selectedTextColor = UIColor(hex: 0xFFFFFF)!
    
    /// 设置未选中 Item 文字颜色
    public var unselectedTextColor = UIColor(hex: 0x8798AF)!
    
    /// 设置当前 Item 颜色
    public var selectedViewColor = UIColor(hex: 0x20A0DA)! {
        didSet {
            selectedView.backgroundColor = selectedViewColor
        }
    }
    
    /// 设置当前 Item 边框宽
    public var selectedViewBorderWidth: CGFloat = 0.0 {
        didSet {
            selectedView.borderWidth = selectedViewBorderWidth
        }
    }
    
    /// 设置当前 Item 边框颜色
    public var selectedViewBorderColor = UIColor(hex: 0x20A0DA)! {
        didSet {
            selectedView.borderColor = selectedViewBorderColor
        }
    }
    
    lazy private var selectedView: UIView = {
        let selectedView = UIView(frame: .zero)
        selectedView.backgroundColor = UIColor(hex: 0x20A0DA)
        selectedView.layer.zPosition = -1
        
        return selectedView
    }()
    
    /// 设置标题数组
    public var titles: [String] = [] {
        didSet {
            self.reloadData {
                guard self.selectedIndex < self.titles.count else { return }
                
                self.selectedView.frame = CGRect(x: 0, y: 0, width: CGFloat(self.width / CGFloat(self.titles.count)), height: self.height)
            }
        }
    }
    
    /// 设置当前选中 index
    public var selectedIndex: Int = 0 {
        willSet {
            if newValue < 0 || newValue >= titles.count {
                return
            }
        }
        didSet {
            DispatchQueue.main.async {
                self.reloadData()
                
                let width = CGFloat(self.width / CGFloat(self.titles.count))
                UIView.animate(withDuration: 0.3) {
                    self.selectedView.frame = CGRect(x: CGFloat(width * CGFloat(self.selectedIndex)), y: 0, width: width, height: self.height)
                } completion: { _ in
                    self.selectedItemHandler?(self.selectedIndex)
                }
            }
        }
    }
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?

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
        backgroundColor = UIColor(hex: 0xF1F4F5)
        delegate = self
        dataSource = self
        bounces = false
        isScrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        cornerRadius = 15
        
        insertSubview(selectedView, at: 0)

        register(SegmentControlItem.self, forCellWithReuseIdentifier: "SegmentControlItem")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        selectedView.cornerRadius = cornerRadius
    }

    public func segmentItemDidSelected(_ selectedItemHandler: @escaping (_ index: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
}

extension SegmentControl: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
 
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(width / CGFloat(titles.count)), height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SegmentControlItem", for: indexPath) as! SegmentControlItem
        cell.titleLabel.text = titles[indexPath.item]
        cell.titleLabel.font = (selectedIndex == indexPath.item) ? selectedTextFont : unselectedTextFont
        cell.titleLabel.textColor = (selectedIndex == indexPath.item) ? selectedTextColor : unselectedTextColor
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedIndex != indexPath.item else {
            return
        }

        selectedIndex = indexPath.item
    }
}

class SegmentControlItem: UICollectionViewCell {
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = bounds
    }
}
