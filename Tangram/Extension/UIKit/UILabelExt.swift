//
//  UILabelExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UILabel {
    /// 预算高度
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = lineBreakMode
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    
    /// 设置是否显示删除线
    @IBInspectable public var strikethrough: Bool {
        get {
            return attributedText?.attribute(.strikethroughStyle, at: 0, effectiveRange: nil) != nil
        }
        set {
            if newValue {
                attributedText = NSAttributedString(string: text!, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            } else {
                attributedText = NSAttributedString(string: text!, attributes: [:])
            }
        }
    }
    
    /// 设置是否显示下划线
    @IBInspectable public var underline: Bool {
        get {
            return attributedText?.attribute(.underlineStyle, at: 0, effectiveRange: nil) != nil
        }
        set {
            if newValue {
                attributedText = NSAttributedString(string: text!, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
            } else {
                attributedText = NSAttributedString(string: text!, attributes: [:])
            }
        }
    }
}
