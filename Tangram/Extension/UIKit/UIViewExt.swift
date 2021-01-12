//
//  UIViewExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift

extension UIView {
    /// 坐标 x
    public var x: CGFloat {
        get {
            return frame.origin.x
        } set(value) {
            frame = CGRect(x: value, y: y, width: width, height: height)
        }
    }
    
    /// 坐标 y
    public var y: CGFloat {
        get {
            return frame.origin.y
        } set(value) {
            frame = CGRect(x: x, y: value, width: width, height: height)
        }
    }
    
    /// 坐标原点
    public var origin: CGPoint {
        get {
            return frame.origin
        } set(value) {
            frame = CGRect(x: value.x, y: value.y, width: width, height: height)
        }
    }
    
    /// 视图宽度
    public var width: CGFloat {
        get {
            return frame.size.width
        } set(value) {
            frame = CGRect(x: x, y: y, width: value, height: height)
        }
    }
    
    /// 视图高度
    public var height: CGFloat {
        get {
            return frame.size.height
        } set(value) {
            frame = CGRect(x: x, y: y, width: width, height: value)
        }
    }
    
    /// 视图大小
    public var size: CGSize {
        get {
            return frame.size
        } set(value) {
            frame = CGRect(x: x, y: y, width: value.width, height: value.height)
        }
    }
    
    // MARK: -
    
    /// 设置边框颜色
    @IBInspectable public var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            guard let color = newValue else {
                layer.borderColor = nil
                return
            }
            layer.borderColor = color.cgColor
        }
    }
    
    /// 设置边框宽度
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 设置圆角
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = abs(CGFloat(Int(newValue * 100)) / 100)
        }
    }
    
    /// 设置部分边框
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = shapeLayer
    }
    
    /// 加阴影
    public func addShadow(offset: CGSize, radius: CGFloat = 3, color: UIColor, opacity: Float, cornerRadius: CGFloat? = nil) {
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        
        if let radius = cornerRadius {
            layer.masksToBounds = false
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        }
    }
    
    /// 截屏
    public func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(bounds: bounds).image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    /// 同时添加多个 subview
    public func addSubviews(_ subviews: UIView...) {
        subviews.forEach(addSubview(_:))
    }
    
    /// 删除视图下的所有 subview
    public func removeAllSubviews() {
        subviews.forEach({ $0.removeFromSuperview() })
    }
    
    /// 获取 view 中的第一响应者
    public var firstResponder: UIView? {
        guard !isFirstResponder else {
            return self
        }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }

        return nil
    }
    
    /// 获取当前视图所在的 ViewController
    public var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIView {
    /// 开始旋转动画
    public func startRotate(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = MAXFLOAT
        rotateAnimation.isRemovedOnCompletion = false
        
        layer.add(rotateAnimation, forKey: "view.animation.rotate")
    }
    
    /// 停止旋转动画
    public func stopRotate() {
        layer.removeAnimation(forKey: "view.animation.rotate")
    }
}

extension UIView {
    public enum presentStyle: Int {
        case center, bottom, top
    }
    
    /// 自定义视图弹出效果支持从中间出来和从底下出来，背景视图支持点击消失
    public func present(_ from: presentStyle = .center, tapBackgroundClose: Bool = false, isFullScreenDisplay: Bool = false, useSafeArea: Bool = false, completionHandler: @escaping () -> Void = {}) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        window.endEditing(true)
        
        tag = 1010122
        
        if isFullScreenDisplay {
            frame = window.bounds
        }
        
        let backgroundView = UIView(frame: window.bounds)
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.0
        backgroundView.tag = 1010123

        // 避免多次 present 同一视图
        let targetClassName = (parentViewController != nil) ? parentViewController?.className : self.className
        
        window.subviews.forEach { view in
            if view.className == targetClassName {
                view.removeFromSuperview()
                window.viewWithTag(1010123)?.removeFromSuperview()
            }
        }

        window.addSubview(backgroundView)
        window.addSubview(self)

        let disposeBag = DisposeBag()
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyboardVisibleHeight in
            self?.y = (Device.height - keyboardVisibleHeight - (self?.height ?? 0)) / 2
        }).disposed(by: disposeBag)
        
        if tapBackgroundClose {
            backgroundView.isUserInteractionEnabled = true
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(backgroundViewOnClick))
            backgroundView.addGestureRecognizer(tapGR)
        }
        
        if from == .center {
            alpha = 0.0
            transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 0.3, animations: {
                backgroundView.alpha = 0.4
                self.alpha = 1
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: { (succes) in
                completionHandler()
            })
        } else if from == .top {
            y = -height
            alpha = 1
            
            UIView.animate(withDuration: 0.3, animations: {
                backgroundView.alpha = 0.4
                
                self.y = 0
            }, completion: { (succes) in
                completionHandler()
            })
        } else {
            y = Device.height
            alpha = 1
            
            var newY = Device.height - height
            
            if useSafeArea, #available(iOS 11.0, *) {
                newY -= safeAreaInsets.bottom
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                backgroundView.alpha = 0.4
                
                self.y = newY
            }, completion: { (succes) in
                completionHandler()
            })
        }
    }
    
    /// 移除自定义视图
    public func dismiss(_ completionHandler: @escaping () -> Void = {}) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        window.endEditing(true)
        
        var backgroundView: UIView?
        
        window.subviews.forEach { subview in
            if subview.tag == 1010123 {
                backgroundView = subview
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            backgroundView?.alpha = 0
            self.alpha = 0
        }, completion: { completed in
            backgroundView?.removeFromSuperview()
            self.removeFromSuperview()
            
            completionHandler()
        })
    }
    
    @objc private func backgroundViewOnClick() {
        dismiss()
    }
}

extension UIView {
    typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

    public enum GradientOrientation {
        case horizontal
        case vertical
        case topLeftBottomRight
        case topRightBottomLeft
        
        var startPoint: CGPoint {
            return points.startPoint
        }
        
        var endPoint: CGPoint {
            return points.endPoint
        }
        
        var points: GradientPoints {
            switch self {
            case .topRightBottomLeft:
                return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
            case .horizontal:
                return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
            }
        }
    }
    
    /// 给视图添加渐变色的代码需要放到 layoutSubviews 或 viewWillLayoutSubviews 中，否则 layer 的 frame 会有问题
    public func applyGradient(_ colors: [UIColor], orientation: GradientOrientation) {
        for layer in layer.sublayers ?? [] where layer.className == "CAGradientLayer" {
            layer.removeFromSuperlayer()
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        gradient.locations = nil
        
        layer.insertSublayer(gradient, at: 0)
    }
}
