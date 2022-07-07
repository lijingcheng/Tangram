//
//  UINavigationBarExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UINavigationBar {
    public func backgroundStyle(color: UIColor) {
        if #available(iOS 13.0, *) {
            let appearance = standardAppearance
            appearance.backgroundColor = color
            
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
        } else {
            setBackgroundImage(UIImage(color: color, size: CGSize(width: Device.width, height: 1)), for: .default)
        }
    }
}
