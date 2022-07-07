//
//  LoadMoreView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// 上拉加载的结果：失败了、还有下一页、没有下一页数据了、第一页都没数据
public enum LoadMoreResult {
    case error, hasNextPage, noMoreDatas, emptyData
}

/// 上拉加载视图，还有下一页数据时，滑到底部时会自动加载、如果上次操作是失败情况则需要手动上拉 60 点后松手进行刷新
class LoadMoreView: UIView {
    private lazy var refreshView: RefreshView = {
        let refreshView = RefreshView(texts: [.refreshing: "正在加载", .none: "上拉刷新", .ready: "释放刷新"])
        refreshView.isHidden = true
        
        return refreshView
    }()
    
    private lazy var bottomView: LoadMoreBottomView = {
        let bottomView = LoadMoreBottomView(text: bottomText)
        bottomView.isHidden = true
        
        return bottomView
    }()
    
    private weak var scrollView: UIScrollView?
    
    private var trigger: CGFloat = 60.0
    private var isRefreshing = false
    private var refreshResult: LoadMoreResult = .emptyData {
        didSet {
            // 上次操作失败或没有数据时不会增加 pageIndex
            if refreshResult == .hasNextPage {
                scrollView?.pageIndex += 1
            }
        }
    }
    
    var refreshIndexPagingHandler: ((_ pageIndex: Int) -> Void)?
    var refreshStampPagingHandler: ((_ pageStamp: String) -> Void)?
    var bottomText = ""
    
    private var refreshStatus: RefreshStatus = .none {
        didSet {
            isRefreshing = (refreshStatus == .refreshing)
            
            refreshView.status = refreshStatus
        }
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: -
    init(scrollView: UIScrollView, bottomText: String = "") {
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        
        self.bottomText = bottomText
        self.scrollView = scrollView
        
        addSubview(refreshView)
        addSubview(bottomView)
        
        self.scrollView?.rx.contentOffset.filter { $0.y > 0 }.subscribe(onNext: { [weak self] contentOffset in
            DispatchQueue.main.async {
                guard let isRefreshing = self?.isRefreshing, !isRefreshing, let refreshResult = self?.refreshResult, refreshResult != .noMoreDatas, refreshResult != .emptyData else {
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
        
        scrollView.rx.observeWeakly(UIScrollView.self, "contentSize").subscribe(onNext: { [weak self] change in
            self?.setNeedsLayout()
        }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if refreshResult == .noMoreDatas, !bottomText.isEmpty {
            frame = CGRect(x: 0.0, y: scrollView?.contentSize.height ?? 0, width: scrollView?.width ?? 0, height: trigger)
        }
        
        refreshView.frame = bounds
        bottomView.frame = bounds
    }
    
    // MARK: -
    func startRefresh() {
        guard let scrollView = self.scrollView, !isRefreshing else {
            return
        }
        
        refreshStatus = .refreshing
        
        var newContentInset = scrollView.contentInset
        newContentInset.bottom += self.trigger
        
        self.scrollView?.contentInset = newContentInset
        self.frame = CGRect(x: 0.0, y: scrollView.contentSize.height, width: scrollView.width, height: self.trigger)
        
        self.refreshIndexPagingHandler?(scrollView.pageIndex)
        self.refreshStampPagingHandler?(scrollView.pageStamp)
        
        ProgressHUD.dismiss()
    }

    func endRefresh(_ result: LoadMoreResult, pageStamp: String) {
        refreshResult = result
        
        if result == .hasNextPage {
            scrollView?.pageStamp = pageStamp
        }
        
        if refreshResult == .noMoreDatas, !bottomText.isEmpty {
            bottomView.isHidden = false
            refreshView.isHidden = true
        } else {
            bottomView.isHidden = true
            refreshView.isHidden = false
        }
        
        frame = .zero
        
        if var contentInset = scrollView?.contentInset, refreshStatus == .refreshing {
            contentInset.bottom -= self.trigger
            scrollView?.contentInset = contentInset
        }
        
        refreshStatus = .none
        
        setNeedsLayout()
    }
}

/// 上拉加载没数据时的底部视图
class LoadMoreBottomView: UIView {
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        textLabel.textColor = UIColor(hex: 0x9FA4B3)
        textLabel.textAlignment = .center

        return textLabel
    }()

    init(text: String) {
        super.init(frame: .zero)
        
        textLabel.text = text

        addSubview(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel.frame = CGRect(x: 0, y: 20, width: Device.width, height: 20)
    }
}
