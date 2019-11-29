//
//  UITableViewExt.swift
//  Tangram
//
//  Created by 李京城 on 2019/9/17.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

extension UITableView {
    /// reload 操作加回调
    public func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    /// 聊藏表格下面的没用的 cell
    public func hideEmptyCells() {
        tableFooterView = UIView(frame: .zero)
    }
}
