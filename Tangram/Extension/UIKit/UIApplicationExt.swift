//
//  UIApplicationExt.swift
//  Tangram
//
//  Created by 李京城 on 2023/2/1.
//  Copyright © 2023 李京城. All rights reserved.
//

import UIKit

extension UIApplication {
    public var keyWindou: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows.first(where: \.isKeyWindow)
    }
}
