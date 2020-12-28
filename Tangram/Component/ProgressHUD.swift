//
//  ProgressHUD.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import SnapKit

/// HUD 样式，支持浅色和深色
public enum ProgressHUDStyle {
    case light, dark
}

/// 支持模态效果，可设置文字
public class ProgressHUD {
    public static var ringColor: UIColor?
    
    fileprivate var backgroundView: UIView = {
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.4
        
        return backgroundView
    }()
    
    fileprivate var hudView: UIView = {
        let hudView = UIView(frame: .zero)
        hudView.alpha = 0
        hudView.backgroundColor = .white
        hudView.addShadow(offset: .zero, radius: 6, color: .darkGray, opacity: 0.4)
        hudView.layer.borderColor = UIColor(hex: 0xE5E5E5)?.cgColor
        hudView.layer.borderWidth = 0.5
        hudView.layer.cornerRadius = 7.5
        // 圆角与阴影并存时需要这样特殊处理下
        let subLayer = CALayer()
        subLayer.frame = hudView.layer.bounds
        subLayer.cornerRadius = 7.5
        subLayer.masksToBounds = true
        hudView.layer.addSublayer(subLayer)
        
        return hudView
    }()
    
    fileprivate var ringView: UIImageView = {
        var ringImage = R.image.icon_progress_hud()
        
        if let ringColor = ProgressHUD.ringColor {
            if #available(iOS 13.0, *) {
                ringImage = ringImage?.withTintColor(ringColor)
            } else {
                ringImage = ringImage?.filled(ringColor)
            }
        }
        
        let ringView = UIImageView(image: ringImage)
        
        return ringView
    }()
    
    fileprivate var textLabel: UILabel? = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textLabel.backgroundColor = .clear
        textLabel.textAlignment = .center
        textLabel.baselineAdjustment = .alignCenters
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(hex: 0x30333B)
        
        return textLabel
    }()
    
    fileprivate static let shared: ProgressHUD = {
        let instance = ProgressHUD()
        return instance
    }()
    
    // MARK: -
    public static func show(_ text: String = "", style: ProgressHUDStyle = .light, isModal: Bool = false, endEditing: Bool = true, inView: UIView? = nil) {
        DispatchQueue(label: "ProgressHUD").sync {
            if endEditing {
                UIApplication.shared.keyWindow?.endEditing(true)
            }
            
            self.dismiss()
            self.shared.showHUDView(text, style: style, isModal: isModal, inView: inView)
        }
    }
    
    public static func dismiss() {
        DispatchQueue(label: "ProgressHUD").sync {
            self.shared.hideHUDView()
        }
    }
    
    // MARK: -
    fileprivate func showHUDView(_ text: String, style: ProgressHUDStyle, isModal: Bool, inView: UIView? = nil) {
        if isModal, let window = UIApplication.shared.windows.first {
            backgroundView.frame = window.bounds
            window.addSubview(backgroundView)
            
            window.addSubview(hudView)
        } else {
            let visibleViewController = UIWindow.visibleViewController()
            
            var superView = visibleViewController?.view
            
            if let view = inView {
                superView = view
            }
            
            superView?.addSubview(hudView)
        }
        
        if style == .dark {
            hudView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        
        hudView.addSubview(ringView)
        
        if !text.isEmpty {
            textLabel!.text = text
            
            if style == .dark {
                textLabel!.textColor = .white
            }
            
            hudView.addSubview(textLabel!)
        }
        
        setHUDViewPosistion()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .curveLinear], animations: {
            self.hudView.alpha = 1
        }, completion: { (success) in
            self.ringView.startRotate()
        })
    }
    
    fileprivate func setHUDViewPosistion() {
        let padding: CGFloat = 16
        let ringSize: CGFloat = 32
        var hudViewWidth: CGFloat = 64
        var hudViewHeight: CGFloat = 64
        
        let maxWidth = hudView.superview?.width ?? 0
        
        if textLabel?.superview != nil {
            let rectLabel = (textLabel?.text?.boundingRect(with: CGSize(width: maxWidth - 105 - padding * 2, height: 100),
                                                           options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                           attributes: [.font: textLabel?.font] as [NSAttributedString.Key: AnyObject],
                                                           context: nil))!
            
            hudViewWidth = max(ceil(rectLabel.size.width) + padding * 2, 64)
            hudViewHeight = max(ceil(rectLabel.size.height) + ringSize + padding * 3, 64)
            
            textLabel?.frame = CGRect(x: padding, y: padding * 2 + ringSize, width: ceil(rectLabel.size.width), height: ceil(rectLabel.size.height))
        }
        
        hudView.snp.remakeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(hudViewWidth)
            make.height.equalTo(hudViewHeight)
        }
        
        ringView.frame = CGRect(x: (hudViewWidth - ringSize) / 2, y: 16, width: ringSize, height: ringSize)
    }
    
    fileprivate func hideHUDView() {
        if hudView.alpha == 1 {
            hudView.alpha = 0
            destroyHUDView()
        }
    }
    
    fileprivate func destroyHUDView() {
        backgroundView.removeFromSuperview()
        textLabel?.removeFromSuperview()
        hudView.removeFromSuperview()
        ringView.removeFromSuperview()
    }
}
