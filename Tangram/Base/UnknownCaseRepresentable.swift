//
//  UnknownCaseRepresentable.swift
//  Tangram
//
//  Created by 李京城 on 2019/8/30.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation

/// 避免在 json 转 model 时因枚举字段没匹配到值而导致转换失败
public protocol UnknownCaseRepresentable: RawRepresentable, CaseIterable where RawValue: Equatable {
    static var unknownCase: Self { get }
}

extension UnknownCaseRepresentable {
    public init(rawValue: RawValue) {
        let value = Self.allCases.first(where: { $0.rawValue == rawValue })
        self = value ?? Self.unknownCase
    }
}
