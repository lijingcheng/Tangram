//
//  UIViewControllerExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Rswift

extension UIViewController {
    private struct AssociatedKeys {
        static var supportRotateKey = "UIViewController.supportRotateKey"
    }
    
    /// 是否要支持屏幕旋转
    public var supportRotate: Bool {
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.supportRotateKey) as? Bool
            return value ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.supportRotateKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 是否正在显示
    public var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }
    
    /// 自定义返回按钮的事件
    public func backBarButtonItemOnClick(_ completionHandler: @escaping () -> Void) {
        let disposeBag = DisposeBag()
        
        let item = UIBarButtonItem(image: R.image.icon_nav_back(), style: .plain, target: nil, action: nil)
        item.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        item.rx.tap.subscribe(onNext: { _ in
            completionHandler()
        }).disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem = item
    }
    
    /// 添加 ChildViewController
    public func addChildViewController(_ child: UIViewController, toContainerView containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// 从 ParentViewController 上移除自己
    public func removeFromParentViewController() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
