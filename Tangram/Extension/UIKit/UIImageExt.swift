//
//  UIImageExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UIImage {
    /// 根据颜色生成图片
    public convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            self.init()
            return
        }
        
        UIGraphicsEndImageContext()
        
        guard let aCgImage = image.cgImage else {
            self.init()
            return
        }
        
        self.init(cgImage: aCgImage)
    }
 
    /// 从图片中心点根据图片size拉伸图片
    public func resizableFromCenter() -> UIImage? {
        let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        
        return resizableImage(withCapInsets: UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x), resizingMode: .stretch)
    }
    
    /// 调整图片大小
    public func resize(size: CGSize) -> UIImage? {
        return UIGraphicsImageRenderer(size: size).image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// 图片染色
    public func filled(_ color: UIColor, blendMode: CGBlendMode = .normal) -> UIImage {
        let drawRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    /// 给图片加圆角
    public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 将图片压缩到指定大小，单位 kb
    public func compressionQuality(size: Int) -> Data? {
        guard size > 0 else {
            return jpegData(compressionQuality: 0.9)
        }
        
        var quality: CGFloat = 0.9
        
        while let data = jpegData(compressionQuality: quality) {
            if data.count < (size * 1024) {
                return data
            }
            quality -= 0.1
            
            if quality <= 0 {
                return data
            }
        }
        
        return jpegData(compressionQuality: 0.9)
    }
}
