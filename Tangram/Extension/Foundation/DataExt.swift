//
//  DataExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension Data {
    /// 追加数据
    public mutating func appendBytes(fromData data: Data) {
        var bytes = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &bytes, count: data.count)
        append(bytes, count: bytes.count)
    }
    
    /// 转成 bytes
    public func getBytes() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count)
        return bytes
    }
    
    /// 转成 JSON 对象
    public func toJSON() -> Any? {
        do {
            return try JSON(data: self).object
        } catch {
            return nil
        }
    }
}
