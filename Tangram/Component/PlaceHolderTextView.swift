//
//  PlaceHolderTextView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 支持 placeHolder 并可以设置其颜色的 UITextView
public class PlaceHolderTextView: UITextView {
    /// 最多输入多少字
    public var max: Int?
    
    /// 当前已输入多少字
    public var current = PublishSubject<Int>()
    
    @IBInspectable public var placeHolder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var placeHolderColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
    }
    
    @objc func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? PlaceHolderTextView {
            if notificationObject === self {
                setNeedsDisplay()
                
                if let max = max, max > 0 {
                    if text.count > max {
                        text = String(text.prefix(max))
                    }
                    
                    current.onNext(text.count)
                }
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
                              width: frame.size.width - textContainerInset.left - textContainerInset.right,
                              height: frame.size.height)
            
            placeHolder.draw(in: rect, withAttributes:
                [NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: placeHolderColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        setNeedsDisplay()
    }
}
