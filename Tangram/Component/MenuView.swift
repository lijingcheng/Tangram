//
//  MenuView.swift
//  Tangram
//
//  Created by 李京城 on 2022/7/7.
//  Copyright © 2022 李京城. All rights reserved.
//

import UIKit

/// 简单样式的菜单，只支持文字，纵向展示
class MenuCell: UITableViewCell {
    static var reuseIdentifier = "menuCellId"
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        
        return titleLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        separatorInset = .zero
        contentView.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
    }
}

public class MenuView: UIView {
    /// 当前 item 字体
    public var selectedTextFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    /// 未选中 item 字体
    public var unselectedTextFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    
    /// 当前 item 文字颜色
    public var selectedTintColor = UIColor(hex: 0x20A0DA)!
    
    /// 未选中 item 文字颜色
    public var unselectedTintColor = UIColor(hex: 0x404C57)!
    
    /// 数据源
    public var items: [String] = []
    
    /// 当前选中 index
    public var selectedIndex = 0
    
    lazy fileprivate var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.rowHeight = 30
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
        
        return tableView
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
    
    // MARK: - public method
    
    /// 设置数据后刷新视图
    public func reloadData() {
        tableView.reloadData()
    }
    
    private var selectedItemHandler: ((_ index: Int) -> Void)?
    
    /// 点击 item 后触发
    public func selectedItemHandler(_ selectedItemHandler: @escaping (_ index: Int) -> Void) {
        self.selectedItemHandler = selectedItemHandler
    }
    
    private func setupViews() {
        cornerRadius = 8
        addShadow(offset: .zero, radius: 3, color: .lightGray, opacity: 0.4)
        
        addSubview(tableView)
    }
}

// MARK: - delegate method
    
extension MenuView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath) as! MenuCell
        cell.titleLabel.text = items[indexPath.item]
        
        if selectedIndex == indexPath.item {
            cell.titleLabel.textColor = selectedTintColor
            cell .titleLabel.font = selectedTextFont
        } else {
            cell.titleLabel.textColor = unselectedTintColor
            cell .titleLabel.font = unselectedTextFont
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        
        selectedItemHandler?(indexPath.item)
    }
}
