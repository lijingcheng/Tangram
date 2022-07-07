//
//  UITabBarItemExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UITabBarItem {
    /// 设置 TabBarItem 上有新消息时的标识
    public func tinyRedDot(_ show: Bool, color: UIColor? = .red) {
        if let tabBarButton = value(forKey: "view") as? UIView {
            tabBarButton.viewWithTag(108801)?.removeFromSuperview()
            
            if show {
                let dotView = UIView(frame: CGRect(x: tabBarButton.width / 2 + 12, y: 5, width: 8, height: 8))
                dotView.tag = 108801
                dotView.backgroundColor = color
                dotView.cornerRadius = 4
                
                tabBarButton.addSubview(dotView)
            }
        }
    }
}
