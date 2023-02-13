//
//  DatePicker.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

/// 选择日期控件
public class DatePicker: UIView {
    fileprivate var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .white
        datePicker.minimumDate = Date(timeIntervalSince1970: -2209017600)
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .wheels

        return datePicker
    }()
    
    fileprivate var horizontalLineView: UIView = {
        let horizontalLineView = UIView(frame: CGRect(x: 0, y: 57, width: Device.width, height: 0.5))
        horizontalLineView.backgroundColor = UIColor(hex: 0xE8E8E8)
        
        return horizontalLineView
    }()

    fileprivate var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitleColor(.darkGray, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        cancelButton.frame = CGRect(x: 0, y: 10, width: 70, height: 40)
        cancelButton.setTitle("取消", for: .normal)
        
        return cancelButton
    }()
    
    fileprivate var confirmButton: UIButton = {
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitleColor(.darkGray, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        confirmButton.frame = CGRect(x: Device.width - 70, y: 10, width: 70, height: 40)
        confirmButton.setTitle("确定", for: .normal)
        
        return confirmButton
    }()

    fileprivate var completionHandler: ((_ date: Date) -> Void)?
    
    fileprivate static let shared: DatePicker = {
        let picker = DatePicker(frame: CGRect(x: 0, y: Device.height, width: Device.width, height: 240))
        picker.backgroundColor = .white

        return picker
    }()
    
    public var minimumDate: Date? {
        didSet {
            datePicker.minimumDate = minimumDate
        }
    }
    
    public var maximumDate: Date? {
        didSet {
            datePicker.maximumDate = maximumDate
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        datePicker.frame = CGRect(x: 0, y: 58, width: Device.width, height: 182)
    }
    
    // MARK: -
    public static func show(_ date: Date?, completionHandler: @escaping (_ date: Date) -> Void) {
        shared.completionHandler = completionHandler
        
        shared.confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        shared.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        shared.addSubview(shared.datePicker)
        shared.addSubview(shared.horizontalLineView)
        shared.addSubview(shared.cancelButton)
        shared.addSubview(shared.confirmButton)
        
        if date != nil {
            shared.datePicker.date = date!
        }
        
        shared.present(.bottom)
    }
    
    @objc fileprivate func confirm() {
        completionHandler?(datePicker.date)
        
        dismiss()
    }
    
    @objc fileprivate func cancel() {
        dismiss()
    }
}
