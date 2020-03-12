//
//  WebViewController.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import WebKit

/// 当向 H5 页面注入 Native 方法后，需要用自己的类作为代理并实现此协议中的方法
@objc public protocol WebViewControllerDelegate {
    @objc optional func webViewMessageHandler(methodName: String, params: Any)
}

public class WebViewController: UIViewController {
    /// 访问地址
    @objc public var url = ""
    
    /// 个别业务需要设置 httpBody
    @objc public var httpBody = ""
    
    /// 导航条上的title
    @objc public var navigationItemTitle = ""
    
    /// 隐藏返回按钮
    @objc public var hideBackBarButton: ObjCBool = false
    
    /// 隐藏关闭按钮
    @objc public var hideCloseBarButton: ObjCBool = true
    
    /// 底部是否需要适配安全区
    @objc public var needSafeAreaBottom: ObjCBool = false
    
    /// 通常 H5 唤起登录页面后，登录成功再返回时需要刷新 WebView
    @objc public var needReloadWebView: ObjCBool = false
    
    /// 需要注入 H5 页面的角本代码
    @objc public var userScript = ""
    
    /// 需要向 H5 页面注入的 Native 方法名称，然后需要扩展 WebViewController 并确认 WKScriptMessageHandler 协议，然后重写 userContentController 方法，来接收 H5 发送的消息，再具体判断需要调用哪个 Native 方法
    @objc public var messageHandlers: [String] = []
    
    /// 当向 H5 页面注入 Native 方法后，需要用自己的类作为代理并实现相关方法
    weak public var messageHandlersDelegate: WebViewControllerDelegate?
    
    /// 使用 webVC 时，如果有业务逻辑上的处理，可以设置这个 delegate，然后把业务代码写在自己的类里
    @objc public weak var navigationDelegate: WKNavigationDelegate? {
        didSet {
            webView.navigationDelegate = navigationDelegate
        }
    }
    
    lazy fileprivate var webView: WKWebView = {
        let script = WKUserScript(source: userScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: CGRect(x: 0, y: Device.statusBarHeight + Device.navigationBarHeight, width: Device.width, height: Device.height - Device.statusBarHeight - Device.navigationBarHeight - (needSafeAreaBottom.boolValue ? Device.safeAreaBottomInset : 0)), configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        return webView
    }()
    
    lazy fileprivate var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: Device.statusBarHeight + Device.navigationBarHeight, width: Device.width, height: 3))
        progressView.progressTintColor = .darkGray
        progressView.trackTintColor = .clear
        
        return progressView
    }()
    
    private var observeProgress: NSKeyValueObservation?

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle
        
        view.backgroundColor = .white
        extendedLayoutIncludesOpaqueBars = true
        
        let backBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_back(), style: .plain, target: self, action: #selector(back))
        backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        let closeBarButtonItem = UIBarButtonItem(image: R.image.icon_nav_close(), style: .plain, target: self, action: #selector(close))
        closeBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        
        navigationItem.leftBarButtonItems = [backBarButtonItem, closeBarButtonItem]
        
        if hideBackBarButton.boolValue {
            closeBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            navigationItem.leftBarButtonItems = [closeBarButtonItem]
        }
        
        if hideCloseBarButton.boolValue {
            navigationItem.leftBarButtonItems = [backBarButtonItem]
        }
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
        if let url = URL(string: url.urlEncoded) {
            var request = URLRequest(url: url)
            
            if !httpBody.isEmpty {
                request.httpMethod = "POST"
                request.httpBody = httpBody.data(using: .utf8)
            }
            
            webView.load(request)
        }
        
        observeProgress = webView.observe(\.estimatedProgress) { [weak self] (webView, change) in
            let estimatedProgress = Float(webView.estimatedProgress)
            if let currentProgress = self?.progressView.progress, estimatedProgress > currentProgress {
                self?.progressView.setProgress(estimatedProgress, animated: true)
                self?.progressView.isHidden = (estimatedProgress == 1)
            }
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if webView.navigationDelegate == nil {
            webView.navigationDelegate = self
        }
        
        if webView.uiDelegate == nil {
            webView.uiDelegate = self
        }
        
        webView.configuration.userContentController.removeAllUserScripts()
        messageHandlers.forEach { [weak self] name in
            guard let self = self else {
                return
            }
            
            self.webView.configuration.userContentController.add(self, name: name)
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !(parent is UINavigationController) {
            webView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - (needSafeAreaBottom.boolValue ? Device.safeAreaBottomInset : 0))
            progressView.y = view.y
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if needReloadWebView.boolValue {
            webView.reload()
            needReloadWebView = false
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if webView.isLoading {
            webView.stopLoading()
        }
        
        messageHandlers.forEach { [weak self] name in
            guard let self = self else {
                return
            }
            
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
        }
        
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0)) {}
    }
    
    deinit {
        if webView.isLoading {
            webView.stopLoading()
        }
        
        webView.navigationDelegate = nil
        observeProgress?.invalidate()
    }
    
    // MARK: -
    @objc private func back() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            close()
        }
    }
    
    @objc private func close() {
        Router.pop()
    }
    
    public func reload() {
        webView.reload()
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    // 发送请求前调用，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "tel" {
            App.call(url.absoluteString)
            
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    // 在收到响应后，决定是否跳转的代理
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 准备加载页面
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    // 在页面内容加载到达mainFrame时会回调此API
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    
    // 页面加载完成
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0, animated: true)
    }
    
    // 页面加载失败
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.setProgress(0, animated: true)
    }
    
    // 页面加载内容过程中发生错误时触发
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        progressView.setProgress(0, animated: true)
    }
    
    // 内存占用过大时页面会白屏，会触发此方法
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

// MARK: - WKUIDelegate
extension WebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        Alert.show(message: message, confirmButtonTitle: "确定") { _ in
            completionHandler()
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        Alert.show(message: message, cancelButtonTitle: "取消", confirmButtonTitle: "确定") { event in
            completionHandler(event == Alert.Event.confirm.rawValue)
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: prompt, message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "完成", style: .default) { [weak alertController] _ in
            completionHandler(alertController?.textFields?.first?.text ?? "")
        })
        
        if Device.isPad {
            alertController.popoverPresentationController?.sourceView = UIWindow.visibleViewController()?.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: Device.width / 2, y: Device.height, width: 1, height: 1)
        }
        
        Router.open(alertController, present: true)
    }
    
    // 创建新 webView，当要跳转的页面是要新开页面时需要特殊处理一下（_blank）
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
}

extension WebViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        messageHandlersDelegate?.webViewMessageHandler?(methodName: message.name, params: message.body)
    }
}
