//
//  UIVisualEffectViewExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UIVisualEffectView {
    /// 根据模糊程度生成 UIVisualEffectView
    public convenience init(blurRadius: CGFloat) {
        let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
        blurEffect.setValue(blurRadius, forKeyPath: "blurRadius")
        
        self.init(effect: blurEffect)
    }
}
