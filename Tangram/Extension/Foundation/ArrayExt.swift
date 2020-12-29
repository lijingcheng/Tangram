//
//  ArrayExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension Array {
    /// 根据类型将字典转成指定对象
    public func decodeTo<T>(_ type: T.Type) -> T? where T: Decodable {
        var data: T?
        do {
            data = try JSONDecoder().decode(type, from: (toJSONString()?.data(using: .utf8))!)
        } catch let error {
            print("Error: decode fail \(error).")
        }
        
        return data
    }
    
    /// 转成 JSON 对象
    public func toJSON() -> Data? {
        do {
            return try JSON(rawValue: self)?.rawData()
        } catch {
            return nil
        }
    }
    
    /// 转成 JSON 字符串
    public func toJSONString() -> String? {
        guard let jsonData = toJSON() else { return nil }
        
        return String(data: jsonData, encoding: .utf8)
    }
    
    /// 去重
    public func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({ filter($0) }).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}

extension Array where Element: Equatable {
    /// 删除数组对象
    mutating public func remove(_ obj: Element) {
        self = self.filter { $0 != obj }
    }
}
