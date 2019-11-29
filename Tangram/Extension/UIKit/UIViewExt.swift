//
//  UIViewExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

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
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        layer.mask = maskLayer
    }
    
    /// 设置部分边框（加了阴影后就需要用这种方式加边框）
    public func roundedCornersWhenHasShadow(_ cornersToRound: UIRectCorner, cornerRadius: CGSize, color: UIColor) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: cornersToRound, cornerRadii: cornerRadius).cgPath
        
        let roundedLayer = CALayer()
        roundedLayer.backgroundColor = color.cgColor
        roundedLayer.frame = bounds
        roundedLayer.mask = maskLayer
        
        layer.insertSublayer(roundedLayer, at: 0)
        backgroundColor = .clear
    }
    
    /// 加阴影
    public func addShadow(offset: CGSize, radius: CGFloat = 3, color: UIColor, opacity: Float, cornerRadius: CGFloat? = nil) {
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        if let radius = cornerRadius {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        }
    }
    
    /// 截屏
    public func screenshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
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
        case center, bottom
    }

    /// 自定义视图弹出效果支持从中间出来和从底下出来，背景视图支持点击消失
    public func present(_ from: presentStyle = .center, tapBGClose: Bool = false, completionHandler: @escaping () -> Void = {}) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        
        window.endEditing(true)
        
        tag = 1010122
        
        let backgroundView = UIView(frame: window.bounds)
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.0
        backgroundView.tag = 1010123
        if tapBGClose {
            backgroundView.isUserInteractionEnabled = true
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(backgroundViewOnClick))
            backgroundView.addGestureRecognizer(tapGR)
        }
        
        window.subviews.forEach { [weak self] view in // 避免多次 addSubview
            if view.className == self?.className {
                view.removeFromSuperview()
                window.viewWithTag(1010123)?.removeFromSuperview()
            }
        }
        
        window.addSubviews(backgroundView, self)

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
        } else {
            y = Device.height
            alpha = 1

            UIView.animate(withDuration: 0.3, animations: {
                backgroundView.alpha = 0.4
                
                self.y = Device.height - self.height
            }, completion: { (succes) in
                completionHandler()
            })
        }
    }
    
    /// 移除自定义视图
    public func dismiss(_ completionHandler: @escaping () -> Void = {}) {
        guard  let window = UIApplication.shared.windows.first else {
            return
        }
        
        window.endEditing(true)
        
        var backgroundView: UIView?
        var currentView: UIView?
        
        window.subviews.forEach { subview in
            if subview.tag == 1010123 {
                backgroundView = subview
            }
            if subview.tag == 1010122 {
                currentView = subview
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            backgroundView?.alpha = 0
            currentView?.alpha = 0
        }, completion: { completed in
            backgroundView?.removeFromSuperview()
            currentView?.removeFromSuperview()
            
            completionHandler()
        })
    }
    
    @objc private func backgroundViewOnClick() {
        dismiss()
    }
}
