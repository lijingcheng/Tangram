//
//  TouchAreaLargenButton.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// 可以将 size 小于 44*44 的按钮的点击区域按大至 44*44
public class TouchAreaLargenButton: UIButton {
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let widthDelta = max(44.0 - bounds.width, 0)
        let heightDelta = max(44.0 - bounds.height, 0)
        
        let bounds = self.bounds.insetBy(dx: -0.5 * widthDelta, dy: -0.5 * heightDelta)

        return bounds.contains(point)
    }
}
