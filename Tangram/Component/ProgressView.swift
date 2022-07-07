//
//  ProgressView.swift
//  Tangram
//
//  Created by 李京城 on 2021/5/17.
//  Copyright © 2021 李京城. All rights reserved.
//

import UIKit

public class ProgressView: UIView {
    private var backgroundView: UIView = {
        let backgroundView = UIView(frame: .zero)
        
        return backgroundView
    }()
    
    private var trackView: UIView = {
        let backgroundView = UIView(frame: .zero)
        
        return backgroundView
    }()
    
    public var progressTintColor = UIColor.lightGray {
        didSet {
            backgroundView.backgroundColor = progressTintColor
        }
    }
    
    public var trackTintColor = UIColor.orange {
        didSet {
            trackView.backgroundColor = trackTintColor
        }
    }
    
    public var progress = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(backgroundView)
        addSubview(trackView)
        
        trackView.backgroundColor = trackTintColor
        backgroundView.backgroundColor = progressTintColor
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        trackView.cornerRadius = cornerRadius
        backgroundView.cornerRadius = cornerRadius
        
        backgroundView.frame = self.bounds
        trackView.frame = CGRect(x: 0, y: 0, width: max(0, min(self.width, self.width * CGFloat(progress))), height: self.height)
    }
}
