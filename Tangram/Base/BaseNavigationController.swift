//
//  BaseNavigationController.swift
//  Tangram
//
//  Created by 李京城 on 2019/10/10.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift

public class BaseNavigationController: UINavigationController {
    private let disposeBag = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
    }

    open override var shouldAutorotate: Bool {
        return true
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let visibleVC = visibleViewController {
            if visibleVC.supportRotate {
                return .allButUpsideDown
            } else {
                for child in visibleVC.children where child.supportRotate {
                    return .allButUpsideDown
                }
            }
        }
        
        return .portrait
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}

extension BaseNavigationController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if !navigationBar.subviews.isEmpty {
            navigationBar.subviews.first?.alpha = 1
        }
        
        if viewController.navigationItem.leftBarButtonItem == nil && !viewController.navigationItem.hidesBackButton {
            if navigationController.viewControllers.count > 1 {
                let item = UIBarButtonItem(image: R.image.icon_nav_back(), style: .plain, target: nil, action: nil)
                item.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
                item.rx.tap.subscribe(onNext: { _ in
                    Router.pop()
                }).disposed(by: disposeBag)

                viewController.navigationItem.leftBarButtonItem = item
            } else {
                viewController.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        addSubViewToVisibleViewController()
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override public func popViewController(animated: Bool) -> UIViewController? {
        addSubViewToVisibleViewController()
        
        return super.popViewController(animated: animated)
    }
    
    override public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        addSubViewToVisibleViewController()
        
        return super.popToViewController(viewController, animated: animated)
    }
    
    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        addSubViewToVisibleViewController()
        
        return super.popToRootViewController(animated: animated)
    }
    
    fileprivate func addSubViewToVisibleViewController() {
        if let backgroundView = navigationBar.value(forKey: "_backgroundView") as? UIView {
            let fromView = UIView(frame: CGRect(x: 0, y: -backgroundView.height, width: Device.width, height: backgroundView.height))
            fromView.backgroundColor = .white
            
            viewControllers.last?.view.addSubview(fromView)
            
            if !navigationBar.subviews.isEmpty {
                navigationBar.subviews.first?.alpha = 0
            }
        }
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
