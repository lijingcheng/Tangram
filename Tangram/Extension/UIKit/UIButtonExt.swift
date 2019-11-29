//
//  UIButtonExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import Kingfisher

extension UIButton {
    /// 加载图片前加代理
    public func setImageURL(_ url: String?, for state: UIControl.State = .normal, placeholder: UIImage? = nil, completed: @escaping (UIImage?) -> Void = { _ in }) {
        guard let url = url else {
            return
        }
        
        kf.setImage(with: URL(string: url), for: state, placeholder: placeholder) { result in
            switch result {
            case .success(let value):
                completed(value.image)
            case .failure:
                completed(nil)
            }
        }
    }
}
