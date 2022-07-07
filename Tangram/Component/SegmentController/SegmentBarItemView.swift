//
//  SegmentBarItemView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// Tab 的选中状态
public enum SegmentBarItemState {
    case normal, selected
}

/// segmentBar 上的 Tab 视图
public class SegmentBarItem {
    var title: String!
    var image: UIImage?
    var attributedTitle: [SegmentBarItemState: NSAttributedString]?
    
    public init(_ title: String = "", image: UIImage? = nil, attributedTitle: [SegmentBarItemState: NSAttributedString]? = nil) {
        self.title = title
        self.image = image
        self.attributedTitle = attributedTitle
    }
}

class SegmentBarItemView: UICollectionViewCell {
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        return titleLabel
    }()
    
    var iconImageView: UIImageView = {
        return UIImageView(frame: .zero)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(iconImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = iconImageView.image?.size ?? .zero
        
        iconImageView.frame = CGRect(x: (width - size.width), y: 0, width: size.width, height: size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        iconImageView.image = nil
    }
}
