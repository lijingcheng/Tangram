//
//  App.swift
//  Tangram
//
//  Created by 李京城 on 2019/8/29.
//  Copyright © 2019 李京城. All rights reserved.
//

import CoreLocation
import UIKit

public struct App {
    /// 版本号
    public static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    /// bundleIdentifier
    public static let bundleId = Bundle.main.bundleIdentifier
    
    /// 用于在启动 app 时获取推送信息
    public static var launchOptions: [String: Any]?
    
    /// 是否为 debug 模式
    #if DEBUG
    public static let isDebugMode = true
    #else
    public static let isDebugMode = false
    #endif
    
    /// 定位权限
    public static var locationServicesEnabled: Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            return false
        }

        switch CLLocationManager.authorizationStatus() {
        case .restricted:
            return false
        case .denied:
            return false
        default:
            return true
        }
    }
    
    // MARK: -

    ///判断 app 是否是第一次启动，inCurrentVersion 为 true 则判断当前版本是否是第一次启动
    public static func isFirstStart(inCurrentVersion: Bool = false) -> Bool {
        let useKey = inCurrentVersion ? "App.isFirstStart.\(App.version)" : "App.isFirstStart"
        
        if UserDefaults.hasKey(useKey) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: useKey)
            return true
        }
    }
    
    /// 打电话时会自动过滤掉 136-0000-0000 中的 "-"
    public static func call(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: "-", with: "").trim())"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
