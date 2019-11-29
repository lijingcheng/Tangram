//
//  IntExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension Int {
    /// 转换金额：分  ->  元
    public func convertToYuan() -> String {
        if self % 100 == 0 {
            return "\(self / 100)"
        } else {
            return String(format: "%g", Double(self) / 100.0)
        }
    }
    
    /// 将总秒数转成 "14 : 24" 这种格式
    public func convertToTime() -> String {
        guard self > 0 else { return "00 : 00" }
        
        return String(format: "%02d : %02d", (self / 60), (self % 60))
    }
}
