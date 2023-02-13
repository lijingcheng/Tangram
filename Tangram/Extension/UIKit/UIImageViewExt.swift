//
//  UIImageViewExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    /// 加载图片
    public func setImageURL(_ url: String?, placeholder: UIImage? = nil, completed: @escaping (UIImage?) -> Void = { _ in }) {
        if placeholder != nil {
            image = placeholder
            backgroundColor = .clear
        }
        
        guard let url = url, !url.isEmpty else {
            return
        }
        
        kf.setImage(with: URL(string: url), placeholder: placeholder, completionHandler: { [weak self] result in
            switch result {
            case .success(let value):
                self?.backgroundColor = .clear
                completed(value.image)
            case .failure:
                completed(nil)
            }
        })
    }
    
    /// 给 UIImageView 加模糊效果
    public func blur(withStyle style: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        clipsToBounds = true
    }
}
