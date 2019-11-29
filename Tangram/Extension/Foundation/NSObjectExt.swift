//
//  NSObjectExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension NSObject {
    /// 根据对象获取相关类名
    public var className: String {
        return String(describing: type(of: self))
    }
    
    /// 根据类获取相关类名
    public class var className: String {
        return String(describing: self)
    }
}
