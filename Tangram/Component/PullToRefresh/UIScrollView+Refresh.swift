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
        static var pageStampKey = "UIScrollView.pageStampKey"
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
    
    /// 当前分页标识
    public var pageStamp: String {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pageStampKey) as? String ?? ""
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pageStampKey, newValue, .OBJC_ASSOCIATION_COPY)
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
    
    /// （通过 pageIndex 分页）设置是否支持下拉刷新和上拉加载，并且一开始调用此方法时是否自动加载一次，pageIndex 是已经计算好的，可用来直接传给接口
    public func supportIndexPaging(pullToRefresh: Bool = false, loadMore: Bool = false, autoRefresh: Bool = true, bottomText: String = "", refreshHandler: @escaping (_ pageIndex: Int) -> Void) {
        if pullToRefresh {
            let pullToRefreshView = PullToRefreshView(scrollView: self)
            pullToRefreshView.refreshIndexPagingHandler = refreshHandler
            pullToRefreshView.tag = 10109090
            addSubview(pullToRefreshView)
        }
        
        if loadMore {
            let loadMoreView = LoadMoreView(scrollView: self, bottomText: bottomText)
            loadMoreView.refreshIndexPagingHandler = refreshHandler
            loadMoreView.tag = 10109091
            addSubview(loadMoreView)
        }

        if autoRefresh {
            refreshHandler(pageIndex)
        }
    }
    
    /// （通过 pageStamp 分页）设置是否支持下拉刷新和上拉加载，并且一开始调用此方法时是否自动加载一次，pageStamp 默认为“”，需要在 endRefresh 时回传新的值，可用来直接传给接口
    public func supportStampPaging(pullToRefresh: Bool = false, loadMore: Bool = false, autoRefresh: Bool = true, bottomText: String = "", refreshHandler: @escaping (_ pageStamp: String) -> Void) {
        if pullToRefresh {
            let pullToRefreshView = PullToRefreshView(scrollView: self)
            pullToRefreshView.refreshStampPagingHandler = refreshHandler
            pullToRefreshView.tag = 10109090
            addSubview(pullToRefreshView)
        }

        if loadMore {
            let loadMoreView = LoadMoreView(scrollView: self, bottomText: bottomText)
            loadMoreView.refreshStampPagingHandler = refreshHandler
            loadMoreView.tag = 10109091
            addSubview(loadMoreView)
        }

        if autoRefresh {
            refreshHandler(pageStamp)
        }
    }
    
    /// 主动刷新，只做第一页的更新
    public func startRefresh() {
        pullToRefreshView?.startRefresh()
    }
    
    /// 结束刷新，下拉刷新时这两个参数不用传值，上拉加载必须传参 result，否则会影响到分页，如果是通过 pageStamp 来做分页需要回传这个值（可以仅在 result == .hasNextPage 时传值，error 或 noMoreDatas 时不传也可以，传了也不会使用），通过 pageIndex 分页不需要传 pageStamp
    public func endRefresh(_ result: LoadMoreResult = .noMoreDatas, pageStamp: String = "") {
        pullToRefreshView?.endRefresh()
        loadMoreView?.endRefresh(result, pageStamp: pageStamp)
    }
    
    /// 结束下拉刷新
    public func endPullRefresh() {
        pullToRefreshView?.endRefresh()
    }
    
    /// 重置下拉刷新和上拉加载功能，可以在调用 support 后用此方法禁用下拉刷新功能
    public func reset() {
        pullToRefreshView?.removeFromSuperview()
        loadMoreView?.removeFromSuperview()
        
        pageIndex = 1
        pageStamp = ""
    }
}
