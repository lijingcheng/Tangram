//
//  Network.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import Alamofire

extension Notification.Name {
    public struct Network {
        /// 在访问接口的时候检测出没有网络
        public static let noConnection = Notification.Name(rawValue: "com.tangram.notification.name.network.noConnection")
        /// 网络状态改变
        public static let statusChanged = Notification.Name(rawValue: "com.tangram.notification.name.network.statusChanged")
    }
}

/// 必须通过设置 Network.shared.host = "https://api.com" 之后才能够正常发起网络请求
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

    /// 管理普通请求和上传请求的 manager
    private var manager: Session
    
    /// 管理下载请求的 manager
    private var downloadManager: Session
    
    /// 检测网络是否正常，当百度倒闭时需要修改此行代码
    private var reachabilityManager = NetworkReachabilityManager(host: "www.baidu.com")
    
    /// 必须设置这个 host 才能够正常发起网络请求
    public var host = ""
    
    /// 超时时间，默认 10 秒
    public var timeoutInterval = 10 {
        didSet {
            manager.sessionConfiguration.timeoutIntervalForRequest = TimeInterval(timeoutInterval)
            manager.sessionConfiguration.timeoutIntervalForResource = TimeInterval(timeoutInterval)
        }
    }
    
    /// 用来标识登录状态的 authToken
    public var authToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "API.Auth.token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "API.Auth.token")
        }
    }
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
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
    
    /// 发送 get 请求
    @discardableResult
    public static func get(_ path: String, parameters: [String: Any] = [:], finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        return request(path, method: .get, parameters: parameters, finishedCallback: finishedCallback)
    }
    
    /// 发送 post 请求
    @discardableResult
    public static func post(_ path: String, parameters: [String: Any] = [:], finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        return request(path, method: .post, parameters: parameters, finishedCallback: finishedCallback)
    }
    
    /// 发送 put 请求
    @discardableResult
    public static func put(_ path: String, parameters: [String: Any] = [:], finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        return request(path, method: .put, parameters: parameters, finishedCallback: finishedCallback)
    }
    
    /// 发送 patch 请求
    @discardableResult
    public static func patch(_ path: String, parameters: [String: Any] = [:], finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        return request(path, method: .patch, parameters: parameters, finishedCallback: finishedCallback)
    }
    
    /// 发送 delete 请求
    @discardableResult
    public static func delete(_ path: String, parameters: [String: Any] = [:], finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        return request(path, method: .delete, parameters: parameters, finishedCallback: finishedCallback)
    }
    
    // MARK: -
    
    private static func request(_ path: String, method: HTTPMethod, parameters: [String: Any], finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        do {
            if !shared.isReachable {
                finishedCallback(nil, Network.Error(code: .offline, msg: "网络异常"))
                NotificationCenter.default.post(name: Notification.Name.Network.noConnection, object: path)

                return nil
            }
            
            var request = URLRequest(url: URL(string: (shared.host + path))!)
            request.httpMethod = method.rawValue
            
            if method == .post {
                request.httpBody = parameters.toJSON()
            }

            if canIgnore(request, manager: shared.manager) {
                return nil
            }
            
            request = try URLEncoding.default.encode(request, with: parameters)
            
            return shared.manager.request(request).validate().responseJSON { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let value):
                        finishedCallback(value as? [String: Any] ?? [:], nil)
                    case .failure(let error):
                        finishedCallback(nil, Network.Error(code: .failure, msg: error.localizedDescription))
                        print("Error: \(response.request?.url?.path ?? "") \(error)")
                    }
                }
            }
        } catch let error {
            finishedCallback(nil, Network.Error(code: .failure, msg: error.localizedDescription))
            print("Error: \(path) \(error)")
        }
        
        return nil
    }
    
    /// 发送 upload 请求，需要限制上传大小的功能 maxSize 需要指定值，单位 kb
    @discardableResult
    public static func upload(_ path: String, data: Data?, finishedCallback: @escaping (_ result: [String: Any]?, _ error: Network.Error?) -> Void) -> DataRequest? {
        guard let uploadData = data else {
            return nil
        }
        
        if !shared.isReachable {
            finishedCallback(nil, Network.Error(code: .offline, msg: "网络异常"))
            NotificationCenter.default.post(name: Notification.Name.Network.noConnection, object: path)
            
            return nil
        }

        let boundary = UUID().uuidString
        
        var request = URLRequest(url: URL(string: (shared.host + path))!)
        request.setValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if canIgnore(request, manager: shared.manager) {
            return nil
        }
        
        return shared.manager.upload(getUploadData(uploadData, boundary: boundary), with: request).validate().responseJSON { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let value):
                    finishedCallback(value as? [String: Any] ?? [:], nil)
                case .failure(let error):
                    finishedCallback(nil, Network.Error(code: .failure, msg: error.localizedDescription))
                    print("Error: \(response.request?.url?.path ?? "") \(error)")
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
                case .failure(let error):
                    finishedCallback(false)
                    print("Error: \(response.request?.url?.path ?? "") \(error)")
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
    
    /// 需要上传的数据
    private static func getUploadData(_ uploadData: Data, boundary: String) -> Data {
        var data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        data.append("Content-Disposition:form-data; name=\"file\"; filename=\"file\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: multipart/form-data\r\n\r\n".data(using: .utf8)!)
        data.append(uploadData)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
    
    /// 取消所有请求
    public static func cancelAllRequest() {
        shared.manager.session.invalidateAndCancel()
    }
}

extension Network {
    public struct Error {
        /// 用于展示“空数据”、“没网络”、“接口失败”异常页面
        public enum Code: Int {
            case none, emptyData, offline, failure
        }
        
        public var code: Code?
        public var msg: String?
    }
}
