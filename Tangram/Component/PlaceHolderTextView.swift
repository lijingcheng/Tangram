//
//  PlaceHolderTextView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 支持 placeHolder 并可以设置其颜色的 UITextView
@IBDesignable
public class PlaceHolderTextView: UITextView {

    @IBInspectable public var placeHolder: NSString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var placeHolderColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? PlaceHolderTextView {
            if notificationObject === self {
                setNeedsDisplay()
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if text.isEmpty {
            guard let placeHolder = placeHolder else { return }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            paragraphStyle.lineBreakMode = .byTruncatingTail
            
            let rect = CGRect(x: textContainerInset.left + 5.0,
                              y: textContainerInset.top,
                              width: width - textContainerInset.left - textContainerInset.right,
                              height: height)
            
            placeHolder.draw(in: rect, withAttributes:
                [NSAttributedString.Key.font: font!, NSAttributedString.Key.foregroundColor: placeHolderColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
