//
//  App.swift
//  Tangram
//
//  Created by 李京城 on 2019/8/29.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import Kingfisher

public struct App {
    /// Apple Store 中的 appId
    public static var storeId = ""
    
    /// App 的用户id
    public static var userId = ""

    /// 项目的 scheme
    public static var scheme = ""
    
    /// App 的 universalLink
    public static var universalLink = ""
    
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
    
    /// 图片代理地址
    public static var imageProxy: String? {
        get {
            return UserDefaults.standard.string(forKey: "App.imageProxy")
        }
        set {
            if let url = newValue, let host = URL(string: url)?.host {
                ImageDownloader.default.trustedHosts?.insert(host)
                UserDefaults.standard.set(url, forKey: "App.imageProxy")
            }
        }
    }
    
    // MARK: -

    /// 打电话，会自动过滤 "-"，例如：136-9134-3119
    public static func call(_ phoneNumber: String) {
        if let url = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: "-", with: "").trim())"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    /// 用于判断 app 是否是第一次启动，onCurrentVersion 为 true 则判断当前版本是否是第一次启动
    public static func isFirstStart(onCurrentVersion: Bool = false) -> Bool {
        let useKey = onCurrentVersion ? "App.isFirstStart.\(App.version)" : "App.isFirstStart"
        
        if UserDefaults.hasKey(useKey) {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: useKey)
            return true
        }
    }
}

public extension App {
    struct Web {
        /// 供 H5 调用的 Native 方法名
        public static var messageHandlers: [String] = []
        
        /// 注入 H5 的代码
        public static var userScript = ""
        
        /// User Agent
        public static var userAgent = ""
    }
    
    struct Vendor {
        /// app 在 QQ 开放平台上的 appId
        public static var qqId = ""
        
        /// app 在 微信开放平台上的 appId
        public static var weixinId = ""
        
        /// app 在微博开放平台上的 appId
        public static var weiboId = ""
    }
    
    struct Data {
        /// 纬度
        @UserDefault("App.Data.latitude")
        public static var latitude: Double?
        
        /// 经度
        @UserDefault("App.Data.longitude")
        public static var longitude: Double?
        
        /// 城市 Id
        @UserDefault("App.Data.cityId")
        public static var cityId: Int?
        
        /// 城市名字
        @UserDefault("App.Data.cityName")
        public static var cityName: String?
    }
}
