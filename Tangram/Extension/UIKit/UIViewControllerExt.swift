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
        static var isFullScreenViewControllerKey = "UIViewController.isFullScreenViewControllerdKey"
        static var supportPushSelfKey = "UIViewController.supportPushSelfKey"
        static var modelParamsKey = "UIViewController.modelParamsKey"
        static var supportPopGestureRecognizerKey = "UIViewController.supportPopGestureRecognizerKey"
        static var callbackDatasKey = "UIViewController.callbackDatasKey"
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
    
    /// 是否可以自己 push 自己，默认 false
    public var supportPushSelf: Bool {
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.supportPushSelfKey) as? Bool
            return value ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.supportPushSelfKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 是否是从最顶端开始做布局的页面
    public var isFullScreenViewController: Bool {
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.isFullScreenViewControllerKey) as? Bool
            return value ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isFullScreenViewControllerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 页面跳转时用来传递自定义 model  对象，可解决跨组件传 model 对象问题（ obj = modelParams?["obj"] as? Model ）
    public var modelParams: [String: Any]? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.modelParamsKey) as? [String: Any]) ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.modelParamsKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 是否支持侧滑返回手势，默认 true
    public var supportPopGestureRecognizer: Bool {
        get {
            let value = objc_getAssociatedObject(self, &AssociatedKeys.supportPopGestureRecognizerKey) as? Bool
            return value ?? true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.supportPopGestureRecognizerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 用于跨组件场景下在 VC 之间回传数据
    public var callbackDatas: PublishSubject<[String: Any]?>? {
        if objc_getAssociatedObject(self, &AssociatedKeys.callbackDatasKey) == nil {
            objc_setAssociatedObject(self, &AssociatedKeys.callbackDatasKey, PublishSubject<[String: Any]?>(), .OBJC_ASSOCIATION_RETAIN)
        }
        
        return objc_getAssociatedObject(self, &AssociatedKeys.callbackDatasKey) as? PublishSubject<[String: Any]?>
    }
    
    /// 是否正在显示
    public var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }

    /// 自定义返回按钮的事件
    public func backBarButtonItemOnClick(_ completionHandler: @escaping () -> Void) {
        let disposeBag = DisposeBag()
        
        let item = UIBarButtonItem(image: R.image.icon_nav_back(), style: .plain, target: nil, action: nil)
        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        item.rx.tap.bind { (_) in
            completionHandler()
        }.disposed(by: disposeBag)
        
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
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}
