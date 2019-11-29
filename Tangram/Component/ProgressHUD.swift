//
//  ProgressHUD.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// HUD 样式，支持浅色和深色
public enum ProgressHUDStyle {
    case light, dark
}

/// 支持模态效果，可设置文字
public class ProgressHUD {
    fileprivate var backgroundView: UIView = {
        let backgroundView = UIView(frame: UIApplication.shared.windows.first!.bounds)
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
        let ringView = UIImageView(image: R.image.icon_progress_hud())
        
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
    public static func show(_ text: String = "", style: ProgressHUDStyle = .light, isModal: Bool = false) {
        DispatchQueue(label: "ProgressHUD").sync {
            UIApplication.shared.windows.first?.endEditing(true)
            
            self.dismiss()
            self.shared.showHUDView(text, style: style, isModal: isModal)
        }
    }
    
    public static func dismiss() {
        DispatchQueue(label: "ProgressHUD").sync {
            self.shared.hideHUDView()
        }
    }
    
    // MARK: -
    fileprivate func showHUDView(_ text: String, style: ProgressHUDStyle, isModal: Bool) {
        if isModal {
            UIApplication.shared.windows.first?.addSubview(backgroundView)
        }
        
        if style == .dark {
            hudView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        
        UIApplication.shared.windows.first?.addSubview(hudView)
        
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
        
        if textLabel?.superview != nil {
            let rectLabel = (textLabel?.text?.boundingRect(with: CGSize(width: Device.width - 105 - padding * 2, height: 100),
                                                           options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                           attributes: [.font: textLabel?.font] as [NSAttributedString.Key: AnyObject],
                                                           context: nil))!
            
            hudViewWidth = max(ceil(rectLabel.size.width) + padding * 2, 64)
            hudViewHeight = max(ceil(rectLabel.size.height) + ringSize + padding * 3, 64)
            
            textLabel?.frame = CGRect(x: padding, y: padding * 2 + ringSize, width: ceil(rectLabel.size.width), height: ceil(rectLabel.size.height))
        }
        
        hudView.frame = CGRect(x: (Device.width - hudViewWidth) / 2, y: (Device.height - hudViewHeight) / 2, width: hudViewWidth, height: hudViewHeight)
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
