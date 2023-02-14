//
//  MourningView.swift
//  Tangram
//
//  Created by 李京城 on 2023/2/14.
//

import UIKit

public class MourningView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        layer.compositingFilter = "saturationBlendMode"
        layer.zPosition = CGFloat.greatestFiniteMagnitude
        backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
