//
//  GuideViewController.swift
//  Tangram
//
//  Created by 李京城 on 2022/7/7.
//  Copyright © 2022 李京城. All rights reserved.
//

import UIKit

/// 新手引导页
class GuideCell: UICollectionViewCell {
    static var reuseIdentifier = "guideCellId"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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

extension App {
    /// 是否需要展示引导页
    public static var needDisplayGuide: Bool {
        if UserDefaults.hasKey("App.guide.needDisplay") {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: "App.guide.needDisplay")
            return true
        }
    }
}

public class GuideViewController: UIViewController {
    /// 引导页需要的图片对象
    public var images: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: Device.width, height: Device.height), collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GuideCell.self, forCellWithReuseIdentifier: GuideCell.reuseIdentifier)
        
        return collectionView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
    }
    
    public override var shouldAutorotate: Bool {
        return false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private var selectedLastItemHandler: (() -> Void)?
    public func selectedLastItemHandler(_ selectedLastItemHandler: @escaping () -> Void) {
        self.selectedLastItemHandler = selectedLastItemHandler
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension GuideViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GuideCell.reuseIdentifier, for: indexPath) as! GuideCell
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == (images.count - 1) {
            selectedLastItemHandler?()
        }
    }
}
