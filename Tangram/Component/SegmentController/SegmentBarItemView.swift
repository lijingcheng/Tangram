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

/// segmentBar 上的 Tab 视图，图片加文字等很多样式都可以通过 attributedTitle 实现效果
public class SegmentBarItem {
    var title: String!
    var attributedTitle: [SegmentBarItemState: NSAttributedString]?
    
    public init(_ title: String = "", attributedTitle: [SegmentBarItemState: NSAttributedString]? = nil) {
        self.title = title
        self.attributedTitle = attributedTitle
    }
}

class SegmentBarItemView: UICollectionViewCell {
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hex: 0x30333B)
        titleLabel.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
    }
}
