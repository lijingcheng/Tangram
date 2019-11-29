//
//  TimerExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/18.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

public extension Timer {
    /// 暂停 Timer
    func pause() {
        guard isValid else {
            return
        }
        
        fireDate = Date.distantFuture
    }
    
    /// 恢复启动 Timer
    func resume() {
        guard isValid else {
            return
        }
        
        fireDate = Date()
    }
}
