//
//  DatePicker.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

public class DatePicker: UIView {
    var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 58, width: Device.width, height: 182))

        return datePicker
    }()
    
    var horizontalLineView: UIView = {
        let horizontalLineView = UIView(frame: CGRect(x: 0, y: 57, width: Device.width, height: 0.5))
        horizontalLineView.backgroundColor = UIColor(hex: 0xE8E8E8)
        
        return horizontalLineView
    }()

    var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitleColor(.darkGray, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        cancelButton.frame = CGRect(x: 0, y: 16, width: 70, height: 40)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        return cancelButton
    }()
    
    var confirmButton: UIButton = {
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitleColor(.darkGray, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        confirmButton.frame = CGRect(x: Device.width - 70, y: 16, width: 70, height: 40)
        confirmButton.setTitle("确定", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        
        return confirmButton
    }()

    var confirmHandler: ((_ date: Date) -> Void)?
    
    public var minimumDate: Date? {
        didSet {
            datePicker.minimumDate = minimumDate
        }
    }
    
    public var maximumDate: Date? {
        didSet {
            datePicker.maximumDate = minimumDate
        }
    }
 
    // MARK: -
    
    public func show(_ defaultDate: Date?, datePickerMode: UIDatePicker.Mode = .date, confirmHandler: @escaping (_ date: Date) -> Void) {
        self.confirmHandler = confirmHandler
        
        frame = CGRect(x: 0, y: Device.height, width: Device.width, height: 240)
        
        datePicker.datePickerMode = datePickerMode
        
        if let date = defaultDate {
            datePicker.date = date
        }
        
        addSubview(datePicker)
        addSubview(horizontalLineView)
        addSubview(cancelButton)
        addSubview(confirmButton)
        
        present(.bottom)
    }
    
    @objc func confirm() {
        confirmHandler?(datePicker.date)
        
        dismiss()
    }
    
    @objc func cancel() {
        dismiss()
    }
}
