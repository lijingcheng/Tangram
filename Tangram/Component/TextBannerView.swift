//
//  TextBannerView.swift
//  Tangram
//
//  Created by 李京城 on 2021/7/20.
//  Copyright © 2021 李京城. All rights reserved.
//

import UIKit

/// 文字轮播，默认两秒一换
class TextBannerCell: UICollectionViewCell {
    static var reuseIdentifier = "textBannerCellId"
    
    lazy fileprivate var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.backgroundColor = .clear
        
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel.text = ""
    }
}

public class TextBannerView: UIView {
    
    /// 设置文本颜色
    public var textColor = UIColor.black
    
    /// 设置文本字体
    public var textFont = UIFont.systemFont(ofSize: 13)
    
    /// 文本滚动间隔，默认两秒
    public var interval = 2
    
    /// 是否循环滚动，默认为 true
    public var supportCircularlyRolling = true
    
    public var items: [String] = [] {
        didSet {
            if supportCircularlyRolling, items.count > 1 {
                var newItems = items
                newItems.insert(items.last!, at: 0)
                newItems.append(items.first!)
                items = newItems
            }
        }
    }

    private var currentPage = 0
    
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
        collectionView.register(TextBannerCell.self, forCellWithReuseIdentifier: TextBannerCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private var timer: Timer?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(collectionView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(collectionView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - public method
    
    /// 设置数据后刷新视图
    public func reloadData() {
        collectionView.reloadData {
            if self.items.count > 1, self.supportCircularlyRolling {
                self.safetyScrollToItem(indexPath: IndexPath(item: 1, section: 0), animated: false)
            }
            
            self.restartPlay()
        }
    }
    
    // MARK: - private method
    
    private func restartPlay() {
        stopTimer() // 放到外面是因为有可能上次 items.count 和这次的不一样
        
        if items.count > 1 {
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
    
    private func safetyScrollToItem(indexPath: IndexPath, animated: Bool = true) {
        guard indexPath.item <= (collectionView.numberOfItems(inSection: 0) - 1) else {
            return
        }
        
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - delegate method
    
extension TextBannerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentPage = 0
        
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextBannerCell.reuseIdentifier, for: indexPath) as! TextBannerCell
        cell.textLabel.text = items[indexPath.item]
        cell.textLabel.textColor = textColor
        cell.textLabel.font = textFont
        
        return cell
    }
}
