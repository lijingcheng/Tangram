//
//  PullToRefreshView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 下拉刷新视图，默认拉 60 点松手后就可以刷新了
class PullToRefreshView: UIView {
    private lazy var refreshView: RefreshView = {
        let refreshView = RefreshView(texts: [.refreshing: "正在刷新", .none: "下拉刷新", .ready: "释放刷新"])
        
        return refreshView
    }()

    private weak var scrollView: UIScrollView?
    
    private var trigger: CGFloat = 60.0
    private var isRefreshing = false
    private var contentInset = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1)
    
    var refreshIndexPagingHandler: ((_ pageIndex: Int) -> Void)?
    var refreshStampPagingHandler: ((_ pageStamp: String) -> Void)?
    
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

        self.scrollView?.rx.contentOffset.filter { $0.y < 0 }.subscribe(onNext: { [weak self] contentOffset in
            DispatchQueue.main.async {
                guard let isRefreshing = self?.isRefreshing, !isRefreshing else {
                    return
                }

                if let scrollView = self?.scrollView {
                    self?.frame = CGRect(x: 0.0, y: 0.0, width: scrollView.width, height: scrollView.contentOffset.y + (self?.contentInset.top ?? 0.0))
                    
                    if !scrollView.isDragging && scrollView.isDecelerating && self?.refreshStatus == .ready {
                        self?.startRefresh()
                    } else {
                        if scrollView.contentOffset.y <= -((self?.trigger ?? 0.0) + (self?.contentInset.top ?? 0.0)) {
                            self?.refreshStatus = .ready
                        } else {
                            self?.refreshStatus = .none
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
        guard let scrollView = self.scrollView, !isRefreshing else {
            return
        }
        
        refreshStatus = .refreshing
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.scrollView?.setContentOffset(CGPoint(x: 0.0, y: -(self.contentInset.top + self.trigger)), animated: false)
            self.scrollView?.contentInset = UIEdgeInsets(top: abs(scrollView.contentOffset.y), left: 0, bottom: 0, right: 0)
            self.frame = CGRect(x: 0.0, y: scrollView.contentOffset.y, width: scrollView.width, height: self.trigger)
        }, completion: {(_ finished: Bool) -> Void in
            self.scrollView?.pageIndex = 1
            self.scrollView?.pageStamp = ""
            
            self.refreshIndexPagingHandler?(scrollView.pageIndex)
            self.refreshStampPagingHandler?(scrollView.pageStamp)
            
            ProgressHUD.dismiss()
        })
    }
    
    func endRefresh() {
        if refreshStatus != .none {
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
                self.scrollView?.contentInset = self.contentInset
            }, completion: {(_ finished: Bool) -> Void in
                self.frame = .zero
                self.refreshStatus = .none
            })
        }
    }
}
