//
//  SegmentBarController.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

@objc public protocol SegmentBarControllerDelegate: NSObjectProtocol {
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView)
}

/// 多 Tab 切换用的视图，用来存储 ViewController，支持滑动
public class SegmentBarController: UIViewController {
    private var pagecontent: [UIViewController]
    
    lazy public var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.scrollsToTop = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "segmentCellId")
        collectionView.isPrefetchingEnabled = true
        return collectionView
    }()
    
    weak var segmentBar: SegmentBar?
    
    public weak var delegate: SegmentBarControllerDelegate?
    
    public var isScrollEnabled = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    /// 是否是用户手动滑动 segmentBarController，如果是点击 segmentBar 触发此值为 false
    private var isDraggingScroll = false
    
    public init(viewControllers: [UIViewController]) {
        self.pagecontent = viewControllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var pageContentDidChangeHandler: ((_ index: Int) -> Void)?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(collectionView)
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    public func scrollToItem(index: Int, animated: Bool = true) {
        guard index >= 0 && index < pagecontent.count else { return }
        
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(CGPoint(x: Int(self.collectionView.width) * index, y: 0), animated: animated)
        }
    }
    
    /// 页面滑动后返回当前 index，此方法更适合脱离 segmentBar 独立使用时用
    public func pageContentDidChange(_ pageContentDidChangeHandler: @escaping (_ index: Int) -> Void) {
        self.pageContentDidChangeHandler = pageContentDidChangeHandler
    }
}

extension SegmentBarController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pagecontent.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.width, height: view.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segmentCellId", for: indexPath)
        
        let viewController = pagecontent[indexPath.item]
        viewController.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(viewController.view)
        
        addChild(viewController)
        viewController.didMove(toParent: self)
        
        return cell
    }
}

extension SegmentBarController: UIScrollViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDraggingScroll = true
    }
    
    /// 滑动过程增加动画效果和文字渐变效果
    public func scrollViewDidScroll(_ scrollView: UIScrollView) { // 第一页和最后一页不用做下面处理
        
        if isDraggingScroll {
            segmentBar?.segmentBarControllerDidScroll(scrollView)
        }
        
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentIndex = Int(abs(scrollView.contentOffset.x / scrollView.width))
        
        segmentBar?.selectedIndex = currentIndex
        
        pageContentDidChangeHandler?(currentIndex)
        
        isDraggingScroll = false
    }
}
