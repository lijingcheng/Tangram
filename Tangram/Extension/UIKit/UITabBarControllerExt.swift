//
//  UITabBarControllerExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UITabBarController {
    /// 是否要支持屏幕旋转
    open override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? false
    }
    
    /// 支持旋转的方向
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    /// 控制状态条是否隐藏
    open override var childForStatusBarHidden: UIViewController? {
        return selectedViewController
    }

    /// 控制状态条样式
    open override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
}
