//
//  LoadMoreView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

/// 上拉加载有三种结果：失败了、还有下一页、没有下一页数据了
public enum LoadMoreResult {
    case error, hasNextPage, noMoreDatas
}

/// 上拉加载视图，还有下一页数据时，滑到距底部 100 点时会自动加载、如果上次操作是失败情况则需要手动上拉 60 点然后再松手进行刷新
class LoadMoreView: UIView {
    private lazy var refreshView: RefreshView = {
        let refreshView = RefreshView(texts: [.refreshing: "正在加载", .none: "上拉刷新", .ready: "释放刷新"])
        
        return refreshView
    }()

    private weak var scrollView: UIScrollView?
    
    private var trigger: CGFloat = 60.0
    private var isRefreshing = false
    private var refreshResult: LoadMoreResult = .noMoreDatas {
        didSet {
            // 上次操作失败或没有数据时不会增加 pageIndex
            if refreshResult == .hasNextPage {
                scrollView?.pageIndex += 1
            }
        }
    }
    
    private var contentInset = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)
    
    var refreshHandler: ((_ pageIndex: Int) -> Void)?
    
    private var refreshStatus: RefreshStatus = .none {
        didSet {
            isRefreshing = (refreshStatus == .refreshing)
            
            refreshView.status = refreshStatus
        }
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: -
    init(scrollView: UIScrollView) {
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        
        self.scrollView = scrollView
        
        addSubview(refreshView)

        self.scrollView?.rx.contentOffset.filter { $0.y > 0 }.subscribe(onNext: { [weak self] contentOffset in
            DispatchQueue.main.async {
                guard let isRefreshing = self?.isRefreshing, !isRefreshing, let refreshResult = self?.refreshResult, refreshResult != .noMoreDatas else {
                    return
                } // 没数据时直接 return

                if let scrollView = self?.scrollView, scrollView.contentSize.height > scrollView.height {
                    if refreshResult == .hasNextPage { // 有下一页数据
                        if (contentOffset.y + scrollView.height) >= scrollView.contentSize.height {
                            self?.startRefresh()
                        }
                    } else {
                        if (contentOffset.y + scrollView.height) > scrollView.contentSize.height { // 上次操作失败了，这里需要手动上拉
                            self?.frame = CGRect(x: 0.0, y: scrollView.contentSize.height, width: scrollView.width, height: scrollView.contentOffset.y + scrollView.height - scrollView.contentSize.height)
                            
                            if !scrollView.isDragging && scrollView.isDecelerating && self?.refreshStatus == .ready {
                                self?.startRefresh()
                            } else {
                                if (scrollView.contentOffset.y + scrollView.height - scrollView.contentSize.height) > (self?.trigger ?? 0.0) {
                                    self?.refreshStatus = .ready
                                } else {
                                    self?.refreshStatus = .none
                                }
                            }
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if scrollView != nil, contentInset == UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1) {
            contentInset = scrollView!.contentInset
        }
        
        refreshView.frame = bounds
    }

    // MARK: -
    func startRefresh() {
        guard let scrollView = scrollView, !isRefreshing else {
            return
        }
        
        refreshStatus = .refreshing
        
        UIView.animate(withDuration: (refreshResult == .hasNextPage) ? 0.0 : 0.3, animations: {
            self.scrollView?.contentInset = UIEdgeInsets(top: self.contentInset.top, left: 0, bottom: self.contentInset.bottom + self.trigger, right: 0)
            self.frame = CGRect(x: 0.0, y: scrollView.contentSize.height, width: scrollView.width, height: self.trigger)
        }, completion: {(_ finished: Bool) -> Void in
            self.refreshHandler?(scrollView.pageIndex)
            ProgressHUD.dismiss()
        })
    }

    func endRefresh(_ result: LoadMoreResult) {
        refreshResult = result
        refreshStatus = .none
        
        frame = .zero
        scrollView?.contentInset = contentInset
    }
}
