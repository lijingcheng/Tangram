//
//  CountDown.swift
//  Tangram
//
//  Created by 李京城 on 2019/8/30.
//  Copyright © 2019 李京城. All rights reserved.
//

import RxSwift
import RxCocoa

/// 通过订阅 time 来时时获取时间变化的回调
public class CountDown {
    /// 每次时间变化时发送事件
    public var time = PublishSubject<Int>()
    /// app 进入后台时间，用于回到前台后计算后台停留时间
    private var appEnterBackgroundTime: Date?
    /// 当间隔大于1秒时有用，每次发送倒计时事件的时间
    private var trggerTime: Date?
    /// 当间隔大于1秒时有用，从触发倒计时事件到进入后台的时间（当间隔时间较长时，有可能出现 timer 还没触发过便退到后台，回到前台重新计算时间时需要把这部分也加入计算）
    private var trggerToBackend = 0
    /// 需要倒计时的时间，随着时间变化会慢慢减少，单位：秒
    private var timeout = 0
    /// 回调间隔，单位：秒
    private var interval = 0
    
    private var timer: Timer?
    
    private let disposeBag = DisposeBag()
    
    public init() {
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe(onNext: { [weak self] notification in
            guard let self = self, self.timeout > 0, let appEnterBackgroundTime = self.appEnterBackgroundTime else {
                return
            }
            
            let backendToForegroundTime = Int(appEnterBackgroundTime.secondsInBetweenDate(Date()))
            
            if backendToForegroundTime > self.timeout {
                self.stop()
            } else {
                self.timeout -= backendToForegroundTime
                self.timeout += self.interval // 再这加上 interval 是因为 timer.resume 后会马上触发 timer，但并不应该马上就去扣减秒数
                
                self.timer?.resume()
            }
        }).disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).subscribe(onNext: { [weak self] notification in
            guard let self = self, self.timeout > 0 else {
                return
            }
            
            self.timer?.pause()
            
            self.appEnterBackgroundTime = Date()
            
            if self.interval > 1 {
                self.trggerToBackend = Int(self.trggerTime?.secondsInBetweenDate(Date()) ?? 0)
            }
        }).disposed(by: disposeBag)
    }
    
    /// 开始倒计时，timeout 和 interval 参数单位是秒，如果要求每分钟回调一次，interval 可设置为 60
    public func start(timeout: Int, interval: Int = 1) {
        self.timeout = timeout
        self.interval = interval
        self.trggerTime = Date()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: { [weak self] timer in
            guard let self = self else {
                return
            }
            
            self.timeout -= (self.interval + self.trggerToBackend)
            self.trggerToBackend = 0
            
            if self.timeout > 0 {
                self.time.onNext(self.timeout)
                self.trggerTime = Date()
            } else {
                self.stop()
            }
        })
    }
    
    /// 结束倒计时
    public func stop() {
        timer?.invalidate()
        time.onNext(0)
    }
    
    deinit {
        timer?.invalidate()
    }
}
