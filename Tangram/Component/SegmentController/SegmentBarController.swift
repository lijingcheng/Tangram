//
//  SegmentBarController.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// 多 Tab 切换用的视图，用来存储 ViewController，支持滑动
public class SegmentBarController: UIViewController {
    private var pagecontent: [UIViewController]
    
    public lazy var collectionView: UICollectionView = {
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
    
    /// 关联 segmentBar，用来互动
    public weak var segmentBar: SegmentBar?
    
    public init(viewControllers: [UIViewController]) {
        pagecontent = viewControllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
    
    public func scrollToItem(index: Int, animated: Bool) {
        guard index >= 0 && index < pagecontent.count else { return }
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: [], animated: animated)
            self.updateChildViewController(index)
        }
    }
    
    /// childVC 必须为当前正在展示的 VC
    public func updateChildViewController(_ selectedIndex: Int?) {
        guard let index = selectedIndex, index >= 0 && index < pagecontent.count else { return }
        
        children.forEach { vc in
            vc.removeFromParent()
        }
        
        let viewController = pagecontent[index]
        addChild(viewController)
        viewController.didMove(toParent: self)
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
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        segmentBar?.selectedIndex = Int(abs(scrollView.contentOffset.x / scrollView.width))
        
        updateChildViewController(segmentBar?.selectedIndex)
    }
    
    /// 滑动过程增加动画效果和文字渐变效果
    public func scrollViewDidScroll(_ scrollView: UIScrollView) { // 第一页和最后一页不用做下面处理
        guard segmentBar != nil else { return }
        
        segmentBar!.segmentBarControllerDidScroll(scrollView)
    }
}
