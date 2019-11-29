//
//  UINavigationBarExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UINavigationBar {
    /// 隐藏下面的线
    public func hideBottomLine(_ hide: Bool) {
        setValue(hide, forKey: "hidesShadow")
    }
}
