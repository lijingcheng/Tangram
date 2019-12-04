//
//  BundleExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension Bundle {
    /// 框架 bundle
    public static var tangram: Bundle {
        if let path = Bundle(for: MultipleLinesFlowLayout.self).path(forResource: "Tangram", ofType: "bundle") {
            return Bundle(path: path)!
        }
        
        return Bundle.main
    }
}
