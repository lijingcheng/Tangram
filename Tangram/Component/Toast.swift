//
//  Toast.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// Toast 视图展示位置
public enum ToastViewPosition {
    case center, bottom
}

/// toast 消息并显示 1.5 秒，内容为空时无效果
public class Toast {
    public static var toastViewBackgroundColor = UIColor(hex: 0x666C7B)?.withAlphaComponent(0.8)
    public static var toastViewCornerRadius: CGFloat = 24.0
    public static var toastViewPosition = ToastViewPosition.center
    
    fileprivate var toastView: UIView = {
        let toastView = UIView(frame: .zero)
        toastView.alpha = 0
        toastView.backgroundColor = Toast.toastViewBackgroundColor
        toastView.layer.cornerRadius = Toast.toastViewCornerRadius
        toastView.layer.masksToBounds = true
        
        return toastView
    }()
    
    fileprivate var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        textLabel.textAlignment = .center
        textLabel.baselineAdjustment = .alignCenters
        textLabel.numberOfLines = 0
        
        return textLabel
    }()
    
    fileprivate var currentTask: Task?
    fileprivate var completionHandler: (() -> Void)?
    
    fileprivate static let shared: Toast = {
        let instance = Toast()
        return instance
    }()
    
    // MARK: -
    public static func show(_ message: String, superView: UIView? = UIApplication.shared.keyWindow, endEditing: Bool = true, completionHandler: @escaping () -> Void = {}) {
        if message.isEmpty {
            return
        }
        
        shared.completionHandler = completionHandler
        
        DispatchQueue.main.async {
            if endEditing {
                UIApplication.shared.keyWindow?.endEditing(true)
            }
            
            self.dismiss()
            self.shared.showToastView(message, superView: superView)
        }
    }
    
    public static func dismiss() {
        shared.hideToastView(0)
    }
    
    // MARK: -
    fileprivate func showToastView(_ statusMessage: String, superView: UIView?) {
        textLabel.text = statusMessage
        toastView.addSubview(textLabel)
        
        superView?.addSubview(toastView)
        
        setToastViewSize()
        setToastViewPosistion(notification: nil)
        registerForKeyboardNotificatoins()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
            self.toastView.alpha = 1
        }, completion: { success in
            self.currentTask = delay(1.5) {
                self.hideToastView(0.15)
            }
        })
    }
    
    fileprivate func setToastViewSize() {
        let superViewWidth = toastView.superview?.width ?? Device.width
        
        var toastViewWidth: CGFloat = superViewWidth - 105
        
        let rectLabel = (textLabel.text?.boundingRect(with: CGSize(width: toastViewWidth - 30 * 2, height: 300),
                                                       options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                       attributes: [.font: textLabel.font] as [NSAttributedString.Key: AnyObject],
                                                       context: nil))!
        
        toastViewWidth = ceil(rectLabel.size.width) + 30 * 2
        let toastViewHeight = max(ceil(rectLabel.size.height) + 12 * 2, 48)
        
        toastView.frame = CGRect(x: (superViewWidth - toastViewWidth) / 2, y: 0, width: toastViewWidth, height: toastViewHeight)
        textLabel.frame = CGRect(x: 30, y: (toastViewHeight - ceil(rectLabel.size.height)) / 2, width: ceil(rectLabel.size.width), height: ceil(rectLabel.size.height))
    }
    
    @objc fileprivate func setToastViewPosistion(notification: NSNotification?) {
        let superViewHeight = toastView.superview?.height ?? Device.height
        
        var keyboardHeight: CGFloat = 0.0
        
        if notification != nil {
            if let keyboardFrame: NSValue = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                if notification!.name == UIResponder.keyboardWillShowNotification || notification!.name == UIResponder.keyboardDidShowNotification {
                    keyboardHeight = keyboardRectangle.height
                }
            }
        }
        
        UIView.animate(withDuration: 0, delay: 0, options: [.allowUserInteraction], animations: {
            switch Toast.toastViewPosition {
            case .center:
                self.toastView.y = (superViewHeight - self.toastView.height / 2 - (keyboardHeight > 0 ? keyboardHeight : 49) - Device.safeAreaBottomInset) / 2
            case .bottom:
                self.toastView.y = superViewHeight - self.toastView.height - (keyboardHeight > 0 ? keyboardHeight : 49) - Device.safeAreaBottomInset - 15
            }
        }, completion: nil)
    }
    
    fileprivate func hideToastView(_ duration: Double) {
        if toastView.alpha == 1 {
            cancel(currentTask)
            
            if duration > 0 {
                UIView.animate(withDuration: duration, animations: {
                    self.toastView.alpha = 0
                }, completion: { (succes) in
                    self.destroyToastView()
                })
            } else {
                toastView.alpha = 0
                destroyToastView()
            }
        }
    }
    
    fileprivate func destroyToastView() {
        NotificationCenter.default.removeObserver(self)
        textLabel.removeFromSuperview()
        toastView.removeFromSuperview()
        
        completionHandler?()
        completionHandler = {}
    }
    
    fileprivate func registerForKeyboardNotificatoins() {
        NotificationCenter.default.addObserver(self, selector: #selector(setToastViewPosistion), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setToastViewPosistion), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setToastViewPosistion), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setToastViewPosistion), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
}
