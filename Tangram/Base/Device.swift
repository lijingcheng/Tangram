//
//  Device.swift
//  Tangram
//
//  Created by 李京城 on 2019/8/30.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

public struct Device {
    /// 获取屏幕宽度
    public static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    /// 获取屏幕高度
    public static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    /// 获取状态栏高度
    public static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    /// 获取导航栏高度
    public static var navigationBarHeight: CGFloat {
        return UIWindow.visibleViewController()?.navigationController?.navigationBar.height ?? 44
    }
    
    /// 获取tabbar高度
    public static var tabBarHeight: CGFloat {
        return 49 + Device.safeAreaBottomInset
    }
    
    /// 判断是否是手机
    public static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 判断是否是平板
    public static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 屏幕顶部安全区高度
    public static var safeAreaTopInset: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20
        }
        return 20
    }
    
    /// 屏幕底部安全区高度
    public static var safeAreaBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }
    
    /// 判断是否是模拟器
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// 获取设备名字
    public static var name: String {
        return UIDevice.current.name
    }
    
    /// 获取设备系统版本
    public static var version: String {
        return UIDevice.current.systemVersion
    }
    
    /// 用于 APNs 的 deviceToken
    @UserDefault("Device.token")
    public static var token: String?
}
