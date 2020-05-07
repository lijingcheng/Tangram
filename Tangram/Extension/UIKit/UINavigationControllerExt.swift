//
//  UINavigationControllerExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UINavigationController {
    /// 将 classNames 参数对应的 vc 从导航堆栈中移除
    public func remove(_ classNames: [String]) {
        var vcs = self.viewControllers
        
        self.viewControllers.forEach { vc in
            if classNames.contains(vc.className) {
                vcs.remove(vc)
            }
        }
        
        self.viewControllers = vcs
    }
    
    /// 支持旋转
    open override var shouldAutorotate: Bool {
        return true
    }
    
    /// 设置旋转方向
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let visibleVC = visibleViewController {
            if visibleVC.supportRotate {
                return .allButUpsideDown
            } else {
                for child in visibleVC.children where child.supportRotate {
                    return .allButUpsideDown
                }
            }
        }
        
        return .portrait
    }
    
    /// 控制状态条是否隐藏
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    /// 控制状态条样式
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
