//
//  Router.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// 返回上一页面的方式
public enum NavPopType: Int {
    case previous = 1 // 上一个
    case root = 2 // 根
    case anchor = 3 // 锚点
    case someone = 4 // 指定一个
}

public class Router {
    /// 根据类名跳转
    public static func open(_ name: String, storyboard: String = "", bundle: Bundle = Bundle.main, params: [String: Any] = [:], animated: Bool = true, present: Bool = false, completion: (() -> Void)? = nil) {
        let viewController = Router.viewControllerWithClassName(name, storyboard: storyboard, bundle: bundle)
        
        Router.open(viewController, params: params, animated: animated, present: present, completion: completion)
    }
    
    /// 根据 ViewController 对象跳转
    public static func open(_ viewController: UIViewController?, params: [String: Any]? = [:], animated: Bool = true, present: Bool = false, completion: (() -> Void)? = nil) {
        guard let visibleVC = UIWindow.visibleViewController(), viewController != visibleVC else { // 不允许 push 当前页面
            return
        }
        
        if let vc = viewController {
            DispatchQueue.main.async {
                if let data = params {
                    vc.setValuesForKeys(data)
                }
                
                if present {
                    vc.modalPresentationStyle = .fullScreen
                    
                    visibleVC.present(vc, animated: animated, completion: { completion?() })
                } else {
                    vc.hidesBottomBarWhenPushed = true
                    
                    visibleVC.navigationController?.push(vc, animated: animated, completion: completion)
                }
            }
        } else {
            print("Error: view controller is nil")
        }
    }
    
    /// 默认返回上一页，也可根据 popType 参数跳转到某一页，或根据锚点跳转到相关页面
    public static func pop(_ name: String = "", popType: NavPopType = .previous, params: [String: Any]? = [:], animated: Bool = true, present: Bool = false, completion: (() -> Void)? = nil) {
        guard let visibleVC = UIWindow.visibleViewController() else {
            return
        }
        
        if present {
            DispatchQueue.main.async {
                visibleVC.dismiss(animated: animated, completion: completion)
            }
            return
        }
        
        guard let navigationController = visibleVC.navigationController else {
            return
        }
        
        var popVC: UIViewController?
        
        var popType = popType
        if !name.isEmpty {
            popType = .someone
        }
        
        switch popType {
        case .previous:
            let vcs = navigationController.viewControllers
            
            if vcs.count > 1 {
                popVC = vcs[vcs.endIndex - 2] // endIndex 不是从 0 算的
            }
        case .root:
            popVC = navigationController.viewControllers.first
        case .anchor:
            navigationController.viewControllers.reversed().forEach({ vc in
                if vc.anchor {
                    popVC = vc
                    return
                }
            })
        case .someone:
            navigationController.viewControllers.reversed().forEach({ vc in
                if vc.className == name {
                    popVC = vc
                    return
                }
            })
        }
        
        Router.pop(popVC, params: params, animated: animated, present: present, completion: completion)
    }
    
    /// 默认返回上一页，也可根据 popType 参数跳转到某一页，或根据锚点跳转到相关页面
    public static func pop(_ viewController: UIViewController?, params: [String: Any]? = [:], animated: Bool = true, present: Bool = false, completion: (() -> Void)? = nil) {
        ProgressHUD.dismiss()
        
        if present {
            DispatchQueue.main.async {
                viewController?.dismiss(animated: animated, completion: completion)
            }
            return
        }
        
        guard let navigationController = UIWindow.visibleViewController()?.navigationController else {
            return
        }
        
        DispatchQueue.main.async {
            var popVC = viewController
            var hasExist = false
            
            if popVC != nil {
                navigationController.viewControllers.forEach({ vc in
                    if vc == popVC {
                        hasExist = true
                        return
                    }
                })
            }
            
            if !hasExist {
                popVC = navigationController.viewControllers.first
            }
            
            if let data = params {
                popVC?.setValuesForKeys(data)
            }
            
            if popVC != nil {
                navigationController.pop(popVC!, animated: animated, completion: completion)
            }
        }
    }

    /// 根据类名获取 ViewController 对象，通过 storyboard 构建的 vc，storyboardId 必须和类名一样，通过 xib 构建的 vc，需要重写 init 并调用 super.init(nibName: nil, bundle: Bundle.xxx)
    public static func viewControllerWithClassName(_ name: String, storyboard: String = "", bundle: Bundle) -> UIViewController? {
        var viewController: UIViewController?
        
        if storyboard.isEmpty {
            var bundleName: String?
            
            if bundle == Bundle.main {
                bundleName = (Bundle.main.infoDictionary!["CFBundleExecutable"] as! String).replacingOccurrences(of: "-", with: "_")
            } else {
                bundleName = bundle.infoDictionary!["CFBundleName"] as? String
            }
            
            if let vc = NSClassFromString((bundleName! + "." + name)) as? UIViewController.Type {
                viewController = vc.init()
            }
        } else {
            viewController = UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: name)
        }
        
        return viewController
    }
    
    /// 切换 tabbar index
    public static func switchTabBarSelectedIndex(index: Int) {
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        
        if let tabBarController = rootVC as? UITabBarController {
            Router.pop(popType: .root, animated: false)

            tabBarController.selectedIndex = index
        }
    }
    
    /// ViewController 间转换加动画
    public static func transition(_ rootViewController: UIViewController?) {
        rootViewController?.modalTransitionStyle = .crossDissolve
        
        UIView.setAnimationsEnabled(false)
        UIView.transition(with: UIApplication.shared.windows.first!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            UIApplication.shared.windows.first?.rootViewController = rootViewController
        }, completion: { _ in
            UIView.setAnimationsEnabled(true)
        })
    }
}

extension UIViewController {
    private struct AssociatedKeys {
        static var anchorKey = "UIViewController.anchorKey"
    }
    
    /// 设置当前 ViewController 是否是锚点，用于 pop 时直接回到此页面
    public var anchor: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.anchorKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.anchorKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    open override func setValue(_ value: Any?, forUndefinedKey key: String) {
        print("Error: \(self.className) 类中不存在属性：\(key)")
    }
}

extension UINavigationController {
    private struct AssociatedKeys {
        static var transformingKey = "UINavigationController.transformingKey"
    }
    
    /// 是否正在 push 或 pop 过程中
    private var transforming: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.transformingKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.transformingKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// pop 操作，支持回调
    func pop(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard !transforming else { return }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
            self.transforming = false
        }
        
        popToViewController(viewController, animated: animated)
        transforming = true
        CATransaction.commit()
    }
    
    /// push 操作，支持回调
    func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        guard !transforming else { return }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
            self.transforming = false
        }
        pushViewController(viewController, animated: animated)
        transforming = true
        CATransaction.commit()
    }
}
