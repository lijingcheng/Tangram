//
//  UIScrollView+Refresh.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 下拉刷新上拉加载
extension UIScrollView {
    private struct AssociatedKeys {
        static var pageIndexKey = "UIScrollView.pageIndexKey"
    }

    /// 当前页号
    public var pageIndex: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pageIndexKey) as? Int ?? 1
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pageIndexKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    /// 下拉刷新视图
    private var pullToRefreshView: PullToRefreshView? {
        return viewWithTag(10109090) as? PullToRefreshView
    }
    
    /// 上拉加载视图
    private var loadMoreView: LoadMoreView? {
        return viewWithTag(10109091) as? LoadMoreView
    }
    
    /// 设置是否支持下拉刷新和上拉加载，并且一开始调用此方法时是否自动加载一次，pageIndex 是已经计算好的，可用来直接传给接口
    public func support(pullToRefresh: Bool = false, loadMore: Bool = false, autoRefresh: Bool = true, bottomText: String = "", refreshHandler: @escaping (_ pageIndex: Int) -> Void) {
        if pullToRefresh {
            let pullToRefreshView = PullToRefreshView(scrollView: self)
            pullToRefreshView.refreshHandler = refreshHandler
            pullToRefreshView.tag = 10109090
            addSubview(pullToRefreshView)
        }
        
        if loadMore {
            let loadMoreView = LoadMoreView(scrollView: self, bottomText: bottomText)
            loadMoreView.refreshHandler = refreshHandler
            loadMoreView.tag = 10109091
            addSubview(loadMoreView)
        }

        if autoRefresh {
            refreshHandler(pageIndex)
        }
    }
    
    /// 主动刷新，只做第一页的更新
    public func startRefresh() {
        pullToRefreshView?.startRefresh()
    }
    
    /// 换个名字，触发刷新数据
    public func reloadRefresh() {
        startRefresh()
    }
    
    /// 结束刷新，上拉加载必须传参，否则会影响到 pageIndex 的值，下拉刷新不用传
    public func endRefresh(_ result: LoadMoreResult? = .noMoreDatas) {
        pullToRefreshView?.endRefresh()
        loadMoreView?.endRefresh(result ?? .noMoreDatas)
    }
    
    /// 结束下拉刷新
    public func endPullRefresh() {
        pullToRefreshView?.endRefresh()
    }
}
