//
//  WebViewController.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import WebKit

public class WebViewController: UIViewController {
    /// 访问地址，可以是 https:// 也可以是 file://
    @objc public var url: String = ""
    
    /// 加载本地 html 时因为要往内容中插入业务数据，所以需要在外面处理好再传进来
    @objc public var htmlString: String = ""
    
    /// 支付业务需要设置 httpBody
    @objc public var httpBody: String = ""
    
    /// 导航条上的title
    @objc public var navigationItemTitle: String?
    
    /// 隐藏返回按钮
    @objc public var hideBackBarButton: ObjCBool = false
    
    /// 隐藏关闭按钮
    @objc public var hideCloseBarButton: ObjCBool = false
    
    /// 底部是否需要适配 iPhoneX
    @objc public var needSafeAreaBottom: ObjCBool = false
    
    /// 是否内嵌在其它 VC 中 （例：SegmentBarController）
    @objc public var isIncludedViewController: ObjCBool = false
    
    /// for h5
    @objc public var needReloadWebView: ObjCBool = false {
        didSet {
            if needReloadWebView.boolValue {
                reload()
            }
        }
    }
    
    /// 是否支持侧滑返回
    @objc public var canPopGestureRecognizer: ObjCBool = true
    
    /// 是否支持滚动
    @objc public var isScrollEnabled: ObjCBool = true
    
    /// 是否隐藏进度条
    @objc public var hiddenProgressView: ObjCBool = false
    
    /// 使用 webVC 时，如果有业务逻辑上的处理，可以设置这个 delegate，然后把业务代码写在自己的类里
    @objc public weak var delegate: WKNavigationDelegate? {
        didSet {
            webView.navigationDelegate = delegate
        }
    }
    
    /// WebView 加载完成
    private var loadDidFinishHandler: ((_ contentHeight: Double) -> Void)?
    
    /// WebView 加载失败
    private var loadDidFailHandler: ((_ error: Error) -> Void)?

    /// 显示网页内容
    lazy fileprivate var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        configuration.applicationNameForUserAgent = App.Web.userAgent
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        var webViewY: CGFloat = Device.safeAreaTopInset + Device.navigationBarHeight

        let webView = WKWebView(frame: CGRect(x: 0, y: webViewY, width: Device.width, height: Device.height - Device.safeAreaTopInset - Device.navigationBarHeight - (needSafeAreaBottom.boolValue ? Device.safeAreaBottomInset : 0)), configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = UIColor(hex: 0xF3F4F5)
        webView.scrollView.isScrollEnabled = isScrollEnabled.boolValue
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        return webView
    }()
    
    /// 展示网页加载进度
    lazy fileprivate var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: webView.y, width: Device.width, height: 2))
        progressView.progressTintColor = UIColor(hex: 0x004696)
        progressView.trackTintColor = .clear
        
        return progressView
    }()
    
    /// 网页加载进度监听器
    private var observeProgress: NSKeyValueObservation?
    
    /// 网页 contentHeight 监听器
    private var observeContentHeight: NSKeyValueObservation?
    
    /// 临时存放 webView 的内容高度，会在加载过程中多次改变
    private var contentHeight: CGFloat = 0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        supportPushSelf = true
        supportPopGestureRecognizer = canPopGestureRecognizer.boolValue
        
        navigationItem.title = navigationItemTitle
        
        view.backgroundColor = UIColor(hex: 0xF3F4F5)
        
        // 设置 leftBarButtonItems
        if !hideBackBarButton.boolValue {
            let backBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_nav_back", in: .tangram, compatibleWith: nil), style: .plain, target: self, action: #selector(back))
            backBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            navigationItem.leftBarButtonItems = [backBarButtonItem]
        }

        if !hideCloseBarButton.boolValue {
            let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_nav_close", in: .tangram, compatibleWith: nil), style: .plain, target: self, action: #selector(close))
            
            if let leftBarButtonItems = navigationItem.leftBarButtonItems, !leftBarButtonItems.isEmpty {
                closeBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: -18, bottom: 0, right: 0)
                
                navigationItem.leftBarButtonItems?.append(closeBarButtonItem)
            } else {
                closeBarButtonItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                
                navigationItem.leftBarButtonItems = [closeBarButtonItem]
            }
        }
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
        if htmlString.isEmpty {
            reload()
        } else {
            webView.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: url))
        }
        
        // 需要隐藏进度条时，只需要不监控进度状态就可以了
        if !hiddenProgressView.boolValue {
            observeProgress = webView.observe(\.estimatedProgress) { [weak self] (webView, change) in
                let estimatedProgress = Float(webView.estimatedProgress)
                
                if let currentProgress = self?.progressView.progress, estimatedProgress > currentProgress {
                    self?.progressView.setProgress(estimatedProgress, animated: true)
                    self?.progressView.isHidden = (estimatedProgress == 1)
                }
            }
        }
        
        observeContentHeight = webView.observe(\.scrollView.contentSize) { [weak self] (webView, change) in
            guard let self = self else {
                return
            }
            
            // contentHeight < 10 不认为 webview 加载出来了，尽量减少不必要的回调
            let height = ceil(webView.scrollView.contentSize.height)
            
            if height != self.contentHeight, height > 10 {
                self.contentHeight = height
                self.loadDidFinishHandler?(height)
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
        webView.configuration.userContentController.addUserScript(WKUserScript(source: App.Web.userScript, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        
        App.Web.messageHandlers.forEach { [weak self] name in
            guard let self = self else {
                return
            }
            
            self.webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
            self.webView.configuration.userContentController.add(self, name: name)
        }
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 如果 addChild 作为其它 ViewController 的子控制器使用，y 需要为 0
        if !(parent is UINavigationController) {
            webView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - (needSafeAreaBottom.boolValue ? Device.safeAreaBottomInset : 0))
            progressView.y = view.y
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if webView.isLoading {
            webView.stopLoading()
        }
        
        if !isIncludedViewController.boolValue {
            App.Web.messageHandlers.forEach { name in
                webView.configuration.userContentController.removeScriptMessageHandler(forName: name)
            }
            
            webView.navigationDelegate = nil
            webView.uiDelegate = nil
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        URLCache.shared.removeAllCachedResponses()
    }
    
    deinit {
        if webView.isLoading {
            webView.stopLoading()
        }
        
        webView.navigationDelegate = nil
        observeProgress?.invalidate()
        observeContentHeight?.invalidate()
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
        contentHeight = 0
        
        if let url = URL(string: url) {
            var request = URLRequest(url: url)
            
            if !httpBody.isEmpty {
                request.httpMethod = "POST"
                request.httpBody = httpBody.data(using: .utf8)
            }
            
            webView.load(request)
        }
    }
    
    /// webView 加载完成
    public func loadDidFinishHandler(_ loadDidFinishHandler: @escaping (_ contentHeight: Double) -> Void) {
        self.loadDidFinishHandler = loadDidFinishHandler
    }
    
    /// webView 加载失败
    public func loadDidFailHandler(_ loadDidFailHandler: @escaping (_ error: Error) -> Void) {
        self.loadDidFailHandler = loadDidFailHandler
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    // 发送请求前调用，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme == "tel" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
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
        progressView.setProgress(0, animated: false)
    }
    
    // 页面加载过程中再次重定向跳转时触发
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else {
            return
        }
        
        progressView.setProgress(0, animated: false)
        
        loadDidFailHandler?(error)
    }
    
    // 页面加载内容过程中发生错误时触发
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else {
            return
        }
        
        progressView.setProgress(0, animated: false)
        
        loadDidFailHandler?(error)
    }
    
    // 内存占用过大时页面会白屏，会触发此方法
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        reload()
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
        
        present(alertController, animated: true)
    }
    
    // 创建新 webView，当要跳转的页面是要新开页面时需要特殊处理一下（_blank）
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
}

// MARK: - WKScriptMessageHandler

extension WebViewController: WKScriptMessageHandler {
    // 接收 H5 发送的消息
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NotificationCenter.default.post(name: Notification.Name.Web.didReceiveScriptMessage, object: message)
    }
}
