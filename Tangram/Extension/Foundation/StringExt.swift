//
//  StringExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import CommonCrypto

extension String {
    /// md5
    public func md5() -> String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    /// 将URL中的"特殊字符"转成“%3A%2F%2F”
    public var urlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    /// 将URL中的“%3A%2F%2F”转成正常字符
    public var urlDecode: String {
        return removingPercentEncoding!
    }

    /// 是否是手机号（1打头的11位数字）
    public var isPhoneNumber: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "^1[0-9]{10}$").evaluate(with: self)
    }
    
    /// 136****3119, 星号也可设置成别的字符
    public func cover(_ separator: String = "****") -> String {
        guard isPhoneNumber else { return self }
        
        return (self as NSString).replacingCharacters(in: NSRange(location: 3, length: 4), with: separator)
    }
    
    /// 136 9134 3119, 空格也可设置成别的
    public func format(_ separator: String = " ") -> String {
        guard self.isPhoneNumber else { return self }
        
        let index1 = index(startIndex, offsetBy: 3)
        let index2 = index(index1, offsetBy: 4)
        
        return "\(self[startIndex..<index1])" + separator + "\(self[index1..<index2])" + separator + "\(self[index2..<endIndex])"
    }
    
    /// 转成 Date，样式可修改
    public func date(withFormat format: String = "yyyy-MM-dd HH:mm") -> Date? {
        let dateFormatter = Date.formatter
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    /// 转成 JSON 对象
    public func toJSON() -> Any? {
        do {
            return try JSON(data: data(using: .utf8)!).object
        } catch {
            return nil
        }
    }
    
    /// 返回去掉首尾空格和新行的字符串
    public func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 按字数裁断字符串，用 ... 表示剩余部分
    public func truncated(toLength length: Int, trailing: String? = "...") -> String {
        guard 1..<count ~= length else { return self }
        return self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
    }

    /// base64 编码
    var base64Encoded: String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    /// base64 解码
    var base64Decoded: String? {
        guard let decodedData = Data(base64Encoded: self) else { return nil }
        return String(data: decodedData, encoding: .utf8)
    }
    
    /// 是否包含字符
    var hasLetters: Bool {
        return rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
    }
    
    /// 是否包含数字
    var hasNumbers: Bool {
        return rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
    }
}
