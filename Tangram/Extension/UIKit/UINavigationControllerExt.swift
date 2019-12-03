//
//  UINavigationControllerExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UINavigationController {
    private struct AssociatedKeys {
        static var lockKey = "UINavigationController.lockKey"
    }
    
    /// remove 时加锁
    private var lock: NSLock {
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.lockKey) as? NSLock
            return value ?? NSLock()
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lockKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// 将 vc 参数从导航堆栈中移除
    public func remove(_ vc: UIViewController?) {
        remove(vc?.className)
    }
    
    /// 将 className 参数对应的 vc 从导航堆栈中移除
    public func remove(_ className: String?) {
        guard let name = className else {
            return
        }
        
        DispatchQueue.main.async {
            self.lock.lock()
            defer { self.lock.unlock() }
            
            var ary = self.viewControllers
            
            for (index, value) in self.viewControllers.enumerated() where value.className == name {
                ary.remove(at: index)
            }
            
            self.viewControllers = ary
        }
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
