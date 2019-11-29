//
//  SegmentBarItemView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// segmentBar 上的 Tab 视图，支持设置标题和旁边的角标文字
public class SegmentBarItem {
    var title: String!
    var badgeValue: String!
    
    public init(_ title: String, badgeValue: String = "") {
        self.title = title
        self.badgeValue = badgeValue
    }
}

class SegmentBarItemView: UICollectionViewCell {
    var segmentBarItem: SegmentBarItem? {
        didSet {
            titleLabel.text = segmentBarItem?.title
            badgeLabel?.text = segmentBarItem?.badgeValue
            badgeLabel?.isHidden = (segmentBarItem?.badgeValue.isEmpty)!
            
            setNeedsLayout()
        }
    }

    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(hex: 0x30333B)
        
        return titleLabel
    }()
    
    private var badgeLabel: UILabel? = {
        let badgeLabel = UILabel(frame: .zero)
        badgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = UIColor(hex: 0xFD9267)
        badgeLabel.textAlignment = .center
        badgeLabel.cornerRadius = 8.0
        
        return badgeLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(badgeLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        
        let titleWidth: CGFloat = ceil(titleLabel.width)
        let titleHeight: CGFloat = ceil(titleLabel.height)
        
        var titleRect = CGRect(x: (width - titleWidth) / 2, y: (height - titleHeight) / 2, width: titleWidth, height: titleHeight)
        
        if !(badgeLabel?.isHidden)! {
            titleRect.origin.x -= 10
            badgeLabel?.frame = CGRect(x: titleRect.maxX + 4, y: (bounds.size.height - 16) / 2, width: 16, height: 16)
        }
        
        titleLabel.frame = titleRect
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
        badgeLabel?.text = ""
        badgeLabel?.isHidden = true
    }
}
