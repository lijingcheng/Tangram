//
//  CircleProgressView.swift
//  Tangram
//
//  Created by 李京城 on 2022/7/7.
//  Copyright © 2022 李京城. All rights reserved.
//

import UIKit

public class CircleProgressView: UIView {
    /// 进度条底色
    public var trackColor: UIColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    /// 进度条显示颜色
    public var progressColor: UIColor = .orange {
        didSet {
            shapeLayer.strokeColor = progressColor.cgColor
        }
    }
    
    /// 线条高度
    public var lineWidth: CGFloat = 5 {
        didSet {
            trackLayer.lineWidth = lineWidth
            shapeLayer.lineWidth = lineWidth
        }
    }
    
    /// 进度
    public var progress: Double = 0 {
        didSet {
            shapeLayer.strokeEnd = CGFloat(progress)
        }
    }
    
    /// 进度条内部视图
    public var contentView: UIView? {
        didSet {
            contentView?.removeFromSuperview()
            if let view = contentView {
                addSubview(view)
            }
        }
    }
    
    lazy private var trackLayer: CAShapeLayer = {
        let trackLayer = CAShapeLayer()
        trackLayer.lineWidth = lineWidth
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeEnd = 1
        
        return trackLayer
    }()
    
    lazy private var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = progressColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = CGFloat(progress)
        
        return shapeLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = (min(width, height) - lineWidth) / 2
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        trackLayer.path = path.cgPath
        shapeLayer.path = path.cgPath
        
        trackLayer.position = CGPoint(x: width / 2, y: height / 2)
        shapeLayer.position = trackLayer.position
        
        trackLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        shapeLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1)
        
        if contentView != nil {
            let widthHeight = min(width, height) - lineWidth * 2
            contentView?.cornerRadius = widthHeight / 2
            contentView?.frame = CGRect(x: lineWidth, y: lineWidth, width: widthHeight, height: widthHeight)
        }
    }
    
    private func setupView() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(shapeLayer)
    }
}
