//
//  TextViewController.swift
//  Tangram
//
//  Created by 李京城 on 2020/12/25.
//  Copyright © 2020 李京城. All rights reserved.
//

import UIKit
import RxSwift

/// 输入文本用的页面
public class TextViewController: UIViewController {
    /// placeholder
    @objc public var placeHolder: String = ""
    
    /// 最多输入多少字
    @objc public var max = Int.max
    
    /// 是否屏蔽 Emoji
    @objc public var shiedEmojiChar = false
    
    /// 需要检查输入内容是否合规的话需要传入正则表达式
    @objc public var pattern: String?

    /// 导航条上的title
    @objc public var navigationItemTitle: String?
    
    /// 可用来订阅
    public var inputText = PublishSubject<String>()
    
    /// 输入文本内容
    lazy fileprivate var textView: PlaceHolderTextView = {
        let textView = PlaceHolderTextView(frame: .zero)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.borderWidth = 0.5
        textView.borderColor = UIColor(hex: 0xE5E5E5)
        textView.cornerRadius = 5
        textView.returnKeyType = .done
        textView.delegate = self
        textView.textColor = .darkGray
        textView.placeHolder = placeHolder
        
        return textView
    }()
    
    lazy fileprivate var remindLabel: UILabel = {
        let textLabel = UILabel(frame: .zero)
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.textColor = .lightGray
        textLabel.backgroundColor = .clear
        textLabel.textAlignment = .right
        
        return textLabel
    }()
    
    private let disposeBag = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navigationItemTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(confirm))
        
        view.backgroundColor = UIColor(hex: 0xF3F4F5)
        extendedLayoutIncludesOpaqueBars = true
        
        view.addSubview(textView)
        view.addSubview(remindLabel)
        
        remindLabel.isHidden = (max == Int.max)
        
        textView.rx.text.orEmpty.asObservable().bind { [weak self] entity in
            guard let max = self?.max else {
                return
            }
            
            var text = entity
            if text.count > max {
                text = String(text.prefix(max))
                self?.textView.text = text
            }
            self?.remindLabel.text = "\(entity.count)/\(max)"
        }.disposed(by: disposeBag)
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        textView.frame = CGRect(x: 10, y: Device.statusBarHeight + Device.navigationBarHeight + 10, width: view.width - 20, height: 100)
        remindLabel.frame = CGRect(x: 10, y: Device.statusBarHeight + Device.navigationBarHeight + 110, width: view.width - 20, height: 20)
    }
    
    @objc private func confirm() {
        guard let text = textView.text, text.count <= max else {
            return
        }
        
        if let pattern = pattern, let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            if regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count)).isEmpty {
                Toast.show("输入内容有错误")
                
                return
            }
        }
        
        if shiedEmojiChar, text.containsEmoji {
            Toast.show("不支持 Emoji 表情")
            
            return
        }
        
        inputText.onNext(text)
        
        Router.pop(params: ["inputText": text])
    }
}

// MARK: - UITextViewDelegate

extension TextViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
