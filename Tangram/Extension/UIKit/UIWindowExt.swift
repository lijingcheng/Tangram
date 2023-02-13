//
//  UIWindowExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UIWindow {
    /// 获取当前正在显示的 ViewController
    public class func visibleViewController() -> UIViewController? {
        let window = UIApplication.shared.keyWindou
        
        return window?.visibleViewController(window?.rootViewController)
    }
    
    private func visibleViewController(_ base: UIViewController?) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return visibleViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return visibleViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return visibleViewController(presented)
        }
        return base
    }
    
    /// 移除所有 present 的自定义视图
    public class func removePresentSubViews() {
        guard  let window = UIApplication.shared.keyWindou else { return }
        
        window.endEditing(true)
        
        window.subviews.forEach { subview in
            if subview.tag == 1010123 || subview.tag == 1010122 { // 半黑蒙板视图和自定义视图，tag 对应的是 UIViewExt.swift 里的 present 方法
                subview.removeFromSuperview()
            }
        }
    }
}
