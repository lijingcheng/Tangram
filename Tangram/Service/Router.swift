//
//  Router.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 返回上一页面的方式
public enum NavPopType: Int {
    case previous = 1 // 上一个
    case root = 2 // 根
    case anchor = 3 // 锚点
    case someone = 4 // 指定一个
}

public protocol TabBarItemProtocol {
    func intValue() -> Int
}

public class Router {
    /// 组件之间跳转需要用这个
    public static func open(_ name: String, storyboard: String = "", bundle: Bundle = Bundle.main, params: [String: Any] = [:], animated: Bool = true, present: Bool = false, completion: (() -> Void)? = nil) {
        let viewController = Router.viewControllerWithClassName(name, storyboard: storyboard, bundle: bundle)
        
        Router.open(viewController, params: params, animated: animated, present: present, completion: completion)
    }

    /// 组件内跳转推荐用这个，用 R.swift 可以省去指定 bundle 的操作
    public static func open(_ viewController: UIViewController?, params: [String: Any]? = [:], animated: Bool = true, present: Bool = false, completion: (() -> Void)? = nil) {
        guard let visibleVC = UIWindow.visibleViewController() else {
            return
        }
        
        if !visibleVC.supportPushSelf, viewController?.className == visibleVC.className {
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
                    if visibleVC.navigationController?.viewControllers.count == 1 {
                        vc.hidesBottomBarWhenPushed = true
                    } else {
                        vc.hidesBottomBarWhenPushed = false
                    }
                    
                    visibleVC.navigationController?.push(vc, animated: animated, completion: completion)
                }
            }
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
            var hasExist = false // 用来判断要 pop 的 VC 是否在堆栈中存在
            
            if popVC != nil {
                navigationController.viewControllers.forEach({ vc in
                    if vc == popVC { // 这里要用对象进行比较，仅用名字的话有可能遇到名字一样但不是一个实例而导致的崩溃
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
    
    /// 切换 tabbar index
    public static func switchTabBarSelectedIndex(index: TabBarItemProtocol, completion: (() -> Void)? = nil) {
        let rootVC = UIApplication.shared.windows.first?.rootViewController
            
        if let tabBarController = rootVC as? UITabBarController {
            Router.pop(popType: .root, animated: false) {
                tabBarController.selectedIndex = index.intValue()
                completion?()
            }
        }
    }
    
    /// ViewController 间转换加动画
    public static func transition(_ rootViewController: UIViewController?) {
        rootViewController?.modalTransitionStyle = .crossDissolve
        
        if let window = UIApplication.shared.windows.first {
            UIView.setAnimationsEnabled(false)
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = rootViewController
            }, completion: { _ in
                UIView.setAnimationsEnabled(true)
            })
        }
    }
    
    /// 根据类名获取 ViewController 对象
    public static func viewControllerWithClassName(_ name: String, storyboard: String = "", bundle: Bundle) -> UIViewController? {
        var viewController: UIViewController?
        
        if storyboard.isEmpty {
            var bundleName: String?
            
            if bundle == Bundle.main {
                bundleName = (Bundle.main.infoDictionary!["CFBundleExecutable"] as! String).replacingOccurrences(of: "-", with: "_")
            } else {
                bundleName = bundle.infoDictionary!["CFBundleName"] as? String
            }
            
            // Swift 语言开发的 VC 对象需要通过 bundle + name 的方式初始化
            if let vc = NSClassFromString((bundleName! + "." + name)) as? UIViewController.Type {
                viewController = vc.init()
            } else {
                // Objective-C 语言开发的 VC 对象在初始化时不需要加 bundle
                if let vc = NSClassFromString(name) as? UIViewController.Type {
                    viewController = vc.init()
                }
            }
        } else {
            viewController = UIStoryboard(name: storyboard, bundle: bundle).instantiateViewController(withIdentifier: name)
        }
        
        return viewController
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
        guard let value = value else {
            return
        }
        
        let properys = Mirror(reflecting: self).children // 不包含计算属性
        
        properys.forEach { propery in
            if propery.label == key {
                self.modelParams?[key] = value
                return
            }
        }
        
        print("\(className) 类中不存在属性：\(key).")
    }
}

extension UINavigationController {
    private struct AssociatedKeys {
        static var transformingKey = "UINavigationController.transformingKey"
    }
    
    /// push 操作，支持回调
    func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        pushViewController(viewController, animated: animated)

        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async {
                completion?()
            }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in
            completion?()
        }
    }

    /// pop 操作，支持回调
    func pop(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        popToViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async {
                completion?()
            }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in
            completion?()
        }
    }

    /// 根据类名获取导航堆栈中的 ViewController 对象
    public func viewControllerWithClassName(_ name: String) -> UIViewController? {
        var popVC: UIViewController?
        
        viewControllers.reversed().forEach({ vc in
            if vc.className == name {
                popVC = vc
                return
            }
        })
        
        return popVC
    }
}
