//
//  BaseViewController.swift
//  WandaFilm-Core
//
//  Created by 李京城 on 2020/10/22.
//  Copyright © 2020 MX. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 通用父类，目前仅用于要支持导航条渐变的页面
open class BaseViewController: UIViewController {
    private var supportNavigationBarColorChange = false
    
    private var navigationBarBackgroundColor: UIColor?
    private var navigationBarTintColor: UIColor?
    private var navigationBarTranslucent = false
    private var navigationBarHideBottomLine = true
    
    private let disposeBag = DisposeBag()
    
    /// 只有在不支持导航条渐变时，可在外部使用此属性
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    
    private var exception: PublishSubject<Int>?
    
    private weak var mainView: UIView?
    
    /// 导航条的标题默认取 title 字段的值，如果需要动态修改导航条标题的话，可以在拿到值后修改 navigationBarTitle
    public var navigationBarTitle: String?
    
    /// 滑动到一定距离后开始渐变的阈(yù)值
    public var gradientThreshold = 150
    
    /// 渐变进度
    public var gradientProgress = PublishSubject<CGFloat>()
    
    /// 设置导航条支持渐变，如果页面支持显示异常视图，需要把 viewModel 中的 exception 对象传进来，否则出异常时状态条和返回按钮的颜色会有问题
    public func supportNavigationBarColorGradualChange(_ mainView: UIView, exception: PublishSubject<Int> = PublishSubject<Int>()) {
        self.mainView = mainView
        self.exception = exception
        
        supportNavigationBarColorChange = true
        
        let appearance = UINavigationBar.appearance().standardAppearance
        navigationBarHideBottomLine = (appearance.shadowColor == nil)
        navigationBarBackgroundColor = appearance.backgroundColor
        navigationBarTintColor = UINavigationBar.appearance().tintColor
        navigationBarTranslucent = UINavigationBar.appearance().isTranslucent

        if let scrollView = mainView as? UIScrollView {
            scrollView.rx.didScroll.subscribe(onNext: { [weak self] _ in
                self?.resetNavigationBarStyle()
            }).disposed(by: disposeBag)
        }
        
        self.exception?.subscribe(onNext: { [weak self] code in
            guard let self = self else {
                return
            }
            
            if code == NetworkError.Code.none.rawValue {
                if let scrollView = mainView as? UIScrollView {
                    scrollView.isScrollEnabled = true
                }
                
                self.supportNavigationBarColorChange = true
                
                self.statusBarStyle = .lightContent
                
                self.changeNavigationBarStyle(hideNavigationBarBottomLine: true, tintColor: .white, backgroundColor: UIColor.white.withAlphaComponent(0))
            } else {
                if let scrollView = mainView as? UIScrollView {
                    scrollView.isScrollEnabled = false
                }
                
                self.supportNavigationBarColorChange = false
                
                self.statusBarStyle = .default
                
                self.title = ""
                
                self.changeNavigationBarStyle(hideNavigationBarBottomLine: self.navigationBarHideBottomLine, tintColor: self.navigationBarTintColor!, backgroundColor: self.navigationBarBackgroundColor!)
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }).disposed(by: disposeBag)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if supportNavigationBarColorChange {
            navigationController?.navigationBar.isTranslucent = true
            
            if mainView is UIScrollView {
                resetNavigationBarStyle() // 这里触发的目的是从别的页面返回时，导航条状态要保持之前的样子
            } else {
                changeNavigationBarStyle(hideNavigationBarBottomLine: true, tintColor: .white, backgroundColor: UIColor.white.withAlphaComponent(0))
            }
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if supportNavigationBarColorChange {
            navigationController?.navigationBar.isTranslucent = false
            
            changeNavigationBarStyle(hideNavigationBarBottomLine: navigationBarHideBottomLine, tintColor: navigationBarTintColor!, backgroundColor: navigationBarBackgroundColor!)
        }
    }
    
    private func resetNavigationBarStyle() {
        guard let scrollView = mainView as? UIScrollView else {
            return
        }

        if scrollView.contentOffset.y > 0 {
            title = navigationBarTitle
            
            let alpha: CGFloat = min(scrollView.contentOffset.y / CGFloat(gradientThreshold), 1)
            
            gradientProgress.onNext(alpha)
            
            changeNavigationBarStyle(hideNavigationBarBottomLine: navigationBarHideBottomLine, tintColor: navigationBarTintColor!.withAlphaComponent(alpha), backgroundColor: navigationBarBackgroundColor!.withAlphaComponent(alpha))
            
            statusBarStyle = (alpha < 1) ? .lightContent : .default
        } else {
            title = ""
            
            statusBarStyle = .lightContent
            
            changeNavigationBarStyle(hideNavigationBarBottomLine: true, tintColor: .white, backgroundColor: UIColor.white.withAlphaComponent(0))
        }
        
        setNeedsStatusBarAppearanceUpdate()
    }

    private func changeNavigationBarStyle(hideNavigationBarBottomLine: Bool, tintColor: UIColor, backgroundColor: UIColor) {
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.backgroundColor = backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: tintColor, .font: UIFont.systemFont(ofSize: 16, weight: .medium)]
            
            if hideNavigationBarBottomLine {
                appearance.shadowColor = .clear
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        navigationController?.navigationBar.tintColor = tintColor
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
         return statusBarStyle
    }
}
