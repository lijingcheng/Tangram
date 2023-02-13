//
//  Alert.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/26.
//  Copyright © 2019 李京城. All rights reserved.
//

import Foundation
import UIKit

/// 支持 actionsheet 样式和多个按钮的 alert 样式（action 可通过 setValue(.orange, forKey: "titleTextColor") 设置按钮字体颜色，alertController 可通过 attributedTitle 和 attributedMessage 修改字体颜色）
public class Alert {
    public enum Event: Int {
        case cancel = -2, confirm = -1
    }
    
    public static func show(_ title: String = "", message: String = "", cancelButtonTitle: String = "", confirmButtonTitle: String = "", otherButtonTitles: [String] = [], preferredStyle: UIAlertController.Style = .alert, completionHandler: @escaping (_ index: Int) -> Void) {
        guard let visibleVC = UIWindow.visibleViewController() else {
            return
        }
        
        UIApplication.shared.keyWindou?.endEditing(true)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alertController.modalPresentationStyle = .overFullScreen
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { (action) in
            completionHandler(Alert.Event.cancel.rawValue)
        }
        alertController.addAction(cancelAction)

        if !confirmButtonTitle.isEmpty {
            let confirmAction = UIAlertAction(title: confirmButtonTitle, style: .default) { (action) in
                completionHandler(Alert.Event.confirm.rawValue)
            }
            alertController.addAction(confirmAction)
        }
        
        for (index, title) in otherButtonTitles.enumerated() {
            let otherAction = UIAlertAction(title: title, style: .default, handler: { (action) in
                completionHandler(index)
            })
            alertController.addAction(otherAction)
        }
        
        if Device.isPad {
            alertController.popoverPresentationController?.sourceView = visibleVC.view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: Device.width / 2, y: Device.height, width: 1, height: 1)
        }
        
        visibleVC.present(alertController, animated: true, completion: nil)
    }

    public static func dismiss(_ completionHandler: @escaping (_ index: Int) -> Void) {
        guard let visibleVC = UIWindow.visibleViewController(), visibleVC is UIAlertController else {
            return
        }
        
        visibleVC.dismiss(animated: true, completion: nil)
    }
}
