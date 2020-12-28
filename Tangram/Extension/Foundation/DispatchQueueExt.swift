//
//  DispatchQueueExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

public typealias Task = (_ cancel: Bool) -> Void

extension DispatchQueue {
    private static var onceTracker = [String]()
    
    /// 只执行一次块中代码
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        
        block()
    }
}

/// 延迟执行块中代码，并可以通过 cancel 方法取消
@discardableResult
public func delay(_ time: TimeInterval, task: @escaping () -> Void) -> Task? {
    func dispatch_later(block: @escaping () -> Void) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    
    var closure: (() -> Void)? = task
    var result: Task?
    
    let delayedClosure: Task = { cancel in
        if let internalClosure = closure {
            if !cancel {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result
}

/// 根据参数任务取消之前延迟执行的代码
public func cancel(_ task: Task?) {
    task?(true)
}
