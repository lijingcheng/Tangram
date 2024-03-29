//
//  RefreshView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 支持不同状态下设置文案
enum RefreshStatus {
    case none, ready, refreshing
}

/// 展示图片和文字的小视图
class RefreshView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)

        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.textColor = UIColor(hex: 0x9FA4B3)
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)

        return textLabel
    }()
    
    private var texts: [RefreshStatus: String] = [:]

    var status: RefreshStatus = .none {
        didSet {
            if status == .refreshing {
                textLabel.text = texts[.refreshing]
                imageView.image = UIImage(named: "icon_pull_hud", in: .tangram, compatibleWith: nil)
                imageView.startRotate()
            } else {
                imageView.image = UIImage(named: "icon_pull_arrow", in: .tangram, compatibleWith: nil)
                imageView.stopRotate()

                if status == .none {
                    textLabel.text = texts[.none]
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.transform = .identity
                    }
                } else if status == .ready {
                    textLabel.text = texts[.ready]
                    UIView.animate(withDuration: 0.3) {
                        self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                    }
                }
            }
            
            setNeedsLayout()
        }
    }

    init(texts: [RefreshStatus: String]) {
        super.init(frame: .zero)
        
        self.texts = texts
        
        addSubview(imageView)
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.frame = CGRect(x: (width - 80) / 2, y: (height - 12) / 2, width: 12, height: 12)
        textLabel.frame = CGRect(x: imageView.x + imageView.width + 8, y: (height - 20) / 2, width: 60, height: 20)
    }
}
