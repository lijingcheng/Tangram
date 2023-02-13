//
//  NotificationNameExt.swift
//  Tangram
//
//  Created by 李京城 on 2020/12/25.
//  Copyright © 2020 李京城. All rights reserved.
//

import UIKit

extension Notification.Name {
    public struct Location {
        /// 定位成功
        public static let didSuccess = Notification.Name(rawValue: "com.tangram.notification.name.location.didSuccess")
        /// 定位失败
        public static let didFailure = Notification.Name(rawValue: "com.tangram.notification.name.location.didFailure")
        /// 需要重新定位
        public static let needReload = Notification.Name(rawValue: "com.tangram.notification.name.location.needReload")
    }
    
    public struct User {
        /// 登录成功
        public static let didLogin = Notification.Name(rawValue: "com.tangram.notification.name.user.didLogin")
        /// 退出成功
        public static let didLogout = Notification.Name(rawValue: "com.tangram.notification.name.user.didLogout")
    }
    
    public struct Network {
        /// 在访问接口的时候检测出没有网络
        public static let noConnection = Notification.Name(rawValue: "com.tangram.notification.name.network.noConnection")
        /// 网络状态改变
        public static let statusChanged = Notification.Name(rawValue: "com.tangram.notification.name.network.statusChanged")
    }
    
    public struct Web {
        /// 接收到 H5 发送过来的消息
        public static let didReceiveScriptMessage = Notification.Name(rawValue: "com.tangram.notification.name.web.didReceiveScriptMessage")
    }
    
    public struct Event {
        /// 首页加载成功
        public static let appLoadFinish = Notification.Name(rawValue: "com.tangram.notification.name.event.appLoadFinish")
    }
}
