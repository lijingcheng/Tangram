//
//  BaseViewModel.swift
//  Tangram
//
//  Created by 李京城 on 2022/7/5.
//  Copyright © 2022 李京城. All rights reserved.
//

import RxSwift
import RxCocoa

open class BaseViewModel {
    /// 子类可复用
    public let disposeBag = DisposeBag()
    
    /// 控制 toast
    public var toast = PublishSubject<String>()
    
    /// 根据 Bool 来控制 loading 状态
    public var loading = PublishSubject<Bool>()
    
    /// 用于显示“空空如也”、“加载失败”、“网络失败”页面
    public var exception = PublishSubject<Int>()
    
    /// 分页加载列表数据源 ( 需配合分页加载的请求方法来使用）
    public var items = BehaviorRelay<[Codable]>(value: [])
    
    public init() {
        toast.subscribe(onNext: { msg in
            Toast.show(msg)
        }).disposed(by: disposeBag)
        
        loading.subscribe(onNext: { status in
            if status {
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }).disposed(by: disposeBag)
    }
}
