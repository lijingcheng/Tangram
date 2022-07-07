//
//  Network.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Alamofire

/// 用于展示“空数据”、“没网络”、“接口失败”异常页面
public struct NetworkError {
    public enum Code: Int {
        case none, emptyData, offline, failure
    }
    
    public var code: Code?
    public var msg: String?
    public var data: [String: Any]?
    
    public init(code: Int, msg: String, data: [String: Any]?) {
        self.code = Code(rawValue: code)
        self.msg = msg
        self.data = data
    }
}

public class Network {
    /// 设置个单例属性是为了让服务器时间、网络状态等属性在 app 启动时只保存一份
    public static let shared = Network()
    
    /// 用来存储服务器和本地时间差
    public var timeIntevalDifference = 0
    
    /// 服务器时间
    public var serverTime: Date? {
        return Date().adding(Calendar.Component.second, value: timeIntevalDifference)
    }
    
    /// 是否有网络
    public var isReachable: Bool {
        return reachabilityManager?.isReachable ?? true
    }
    
    /// 当前网络是否是 wiki
    public var isReachableWiFi: Bool {
        return reachabilityManager?.isReachableOnEthernetOrWiFi ?? false
    }
    
    /// 网络请求管理类的通用设置对象
    public var configuration: URLSessionConfiguration

    /// 管理普通请求和上传请求的 manager
    public var manager: Session
    
    /// 管理下载请求的 manager
    public var downloadManager: Session
    
    /// 检测网络是否正常，当百度倒闭时需要修改此行代码
    private var reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")
    
    /// 超时时间，默认 10 秒
    public var timeoutInterval: TimeInterval = 10 {
        didSet {
            manager.sessionConfiguration.timeoutIntervalForRequest = timeoutInterval
            manager.sessionConfiguration.timeoutIntervalForResource = timeoutInterval
        }
    }
    
    /// 用来标识登录状态的 authToken
    @UserDefault("Network.Auth.token")
    public var authToken: String?
    
    private init() {
        configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        configuration.httpMaximumConnectionsPerHost = 6
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true // 网络不通时 request 会等有网后再发出去
        }
        
        manager = Session(configuration: configuration)
        downloadManager = Session(configuration: configuration)
        
        reachabilityManager?.startListening(onUpdatePerforming: { status in
            NotificationCenter.default.post(name: Notification.Name.Network.statusChanged, object: nil)
        })
    }
    
    // MARK: -
    
    /// 发送 http 请求，支持 mock
    @discardableResult
    public static func request(_ url: String, method: HTTPMethod, parameters: [String: Any], postJSONBody: Bool = false, mockFile: String = "", finishedCallback: @escaping (_ result: Any?, _ error: NetworkError?) -> Void) -> DataRequest? {
        do {
            if App.isDebugMode, !mockFile.isEmpty, let filePath = Bundle.main.path(forResource: mockFile, ofType: mockFile.hasSuffix(".json") ? "" : "json") {
                if let result = try? JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: filePath)), options: []) {
                    finishedCallback(result, nil)
                } else {
                    finishedCallback(nil, NetworkError(code: NetworkError.Code.failure.rawValue, msg: "JSON 文件格式不正确，解析失败", data: nil))
                }
                
                return nil
            }
            
            if !shared.isReachable {
                finishedCallback(nil, NetworkError(code: NetworkError.Code.offline.rawValue, msg: "网络无连接，请检查网络", data: ["url": url]))
                NotificationCenter.default.post(name: Notification.Name.Network.noConnection, object: url)

                return nil
            }
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = method.rawValue
            
            if canIgnore(request, manager: shared.manager) {
                return nil
            }
            
            if method == .post, postJSONBody {
                request = try JSONEncoding.default.encode(request, with: parameters)
            } else {
                request = try URLEncoding.default.encode(request, with: parameters)
            }
            
            return shared.manager.request(request).validate().responseData { response in
                DispatchQueue.main.async {
                    if let error = response.error {
                        finishedCallback(AFDataResponse<Any>(request: response.request, response: response.response, data: nil, metrics: response.metrics, serializationDuration: response.serializationDuration, result: Result.failure(error)), nil)
                    } else {
                        if let responseData = response.data, let data = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                            finishedCallback(AFDataResponse(request: response.request, response: response.response, data: responseData, metrics: response.metrics, serializationDuration: response.serializationDuration, result: Result.success(data)), nil)
                        } else {
                            finishedCallback(AFDataResponse(request: response.request, response: response.response, data: nil, metrics: response.metrics, serializationDuration: response.serializationDuration, result: Result.success([:])), nil)
                        }
                    }
                }
            }
        } catch _ {
            finishedCallback(nil, NetworkError(code: NetworkError.Code.failure.rawValue, msg: "请求失败，请稍后重试", data: ["url": url]))
        }
        
        return nil
    }
    
    /// 发送 upload 请求，仅支持上传图片，maxSize 可限制图片上传大小(单位 kb)，gif图需要以 data 形式传入，其它图片可以是 data 或 UIImage（注：图片最好都是以 url 初始化成 data，这样文件大小不会像 UIImage 那样暴涨）
    @discardableResult
    public static func upload(_ url: String, parameters: [String: Any] = [:], datas: [String: Any?]?, maxSize: Int = 0, finishedCallback: @escaping (_ result: Any?, _ error: NetworkError?) -> Void) -> DataRequest? {
        if !shared.isReachable {
            finishedCallback(nil, NetworkError(code: NetworkError.Code.offline.rawValue, msg: "网络无连接，请检查网络", data: ["url": url]))
            NotificationCenter.default.post(name: Notification.Name.Network.noConnection, object: url)
            
            return nil
        }
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        if canIgnore(request, manager: shared.manager) {
            return nil
        }
        
        return shared.manager.upload(multipartFormData: { multipartFormData in
            parameters.forEach { (key, value) in
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            
            datas?.forEach({ (key, value) in
                if let image = value as? UIImage {
                    if let data = image.compressionQuality(size: maxSize) {
                        multipartFormData.append(data, withName: key, fileName: "\(key).jpg", mimeType: "image/jpg")
                    }
                } else if let data = value as? Data {
                    if data.kf.imageFormat == .GIF {
                        multipartFormData.append(data, withName: key, fileName: "\(key).gif", mimeType: "image/gif")
                    } else {
                        if let data2 = UIImage(data: data)?.compressionQuality(size: maxSize) {
                            multipartFormData.append(data2, withName: key, fileName: "\(key).jpg", mimeType: "image/jpg")
                        }
                    }
                }
            })
        }, to: url).validate().responseData { response in
            DispatchQueue.main.async {
                if let error = response.error {
                    finishedCallback(AFDataResponse<Any>(request: response.request, response: response.response, data: nil, metrics: response.metrics, serializationDuration: response.serializationDuration, result: Result.failure(error)), nil)
                } else {
                    if let responseData = response.data, let data = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                        finishedCallback(AFDataResponse(request: response.request, response: response.response, data: responseData, metrics: response.metrics, serializationDuration: response.serializationDuration, result: Result.success(data)), nil)
                    } else {
                        finishedCallback(AFDataResponse(request: response.request, response: response.response, data: nil, metrics: response.metrics, serializationDuration: response.serializationDuration, result: Result.success([:])), nil)
                    }
                }
            }
        }
    }
    
    /// 发送 download 请求
    @discardableResult
    public static func download(_ url: String, fileName: String, finishedCallback: @escaping (_ success: Bool) -> Void = { _ in }) -> DownloadRequest? {
        guard let url = URL(string: url) else {
            return nil
        }
        
        if !shared.isReachable {
            finishedCallback(false)
            NotificationCenter.default.post(name: Notification.Name.Network.noConnection, object: url)
     
            return nil
        }
        
        let request = URLRequest(url: url)
        
        if canIgnore(request, manager: shared.downloadManager) {
            return nil
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            return (URL(fileURLWithPath: FileManager.downloadDirectoryPath(fileName)), [.createIntermediateDirectories, .removePreviousFile])
        }
        
        return shared.downloadManager.download(request, to: destination).responseData { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success:
                    finishedCallback(true)
                case .failure:
                    finishedCallback(false)
                }
            }
        }
    }
}

extension Network {
    /// 是否忽略请求，目的是不多次请求同一接口
    private static func canIgnore(_ request: URLRequest, manager: Session) -> Bool {
        var canIgnore = false
    
        manager.session.getAllTasks { tasks in
            for task in tasks where request.url?.absoluteString == task.originalRequest?.url?.absoluteString {
                canIgnore = true
                break
            }
        }
        
        return canIgnore
    }
    
    /// 取消所有请求
    public static func cancelAllRequest() {
        shared.manager.session.invalidateAndCancel()
    }
}
