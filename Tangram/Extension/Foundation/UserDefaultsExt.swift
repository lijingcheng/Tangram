//
//  UserDefaultsExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/19.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

extension UserDefaults {
    /// 是否存储了 key 指向的对象
    public static func hasKey(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
