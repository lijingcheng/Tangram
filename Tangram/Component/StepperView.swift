//
//  StepperView.swift
//  Tangram
//
//  Created by 李京城 on 2019/11/27.
//  Copyright © 2019 李京城. All rights reserved.
//

import UIKit

public class StepperView: UIView {
    private var subtractButton: UIButton = {
        let subtractButton = UIButton(type: .custom)
        subtractButton.setTitle("-", for: .normal)
        subtractButton.addTarget(self, action: #selector(subtract), for: .touchUpInside)
        
        return subtractButton
    }()
    
    var numberLabel: UILabel = {
        let numberLabel = UILabel(frame: .zero)
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        numberLabel.textAlignment = .center
        numberLabel.textColor = .darkGray
        
        return numberLabel
    }()

    private var addButton: UIButton = {
        let addButton = UIButton(type: .custom)
        addButton.setTitle("+", for: .normal)
        addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
        
        return addButton
    }()
    
    private var currentNumber = 0 {
        didSet {
            if currentNumber <= minNumber {
                subtractButton.isEnabled = false
            } else if currentNumber >= maxNumber {
                addButton.isEnabled = false
            } else {
                subtractButton.isEnabled = true
                addButton.isEnabled = true
            }
            numberLabel.text = String(currentNumber)
        }
    }
    
    public var minNumber = 1
    public var maxNumber = 99
    
    private var numberChangeHandler: ((_ currentNumber: Int) -> Void)?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(subtractButton)
        addSubview(numberLabel)
        addSubview(addButton)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        subtractButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        numberLabel.frame = CGRect(x: 30, y: 0, width: width - 60, height: 30)
        addButton.frame = CGRect(x: width - 30, y: 0, width: 30, height: 30)
    }
    
    // MARK: -
    
    public func numberDidChange(_ numberChangeHandler: @escaping (_ currentNumber: Int) -> Void) {
        self.numberChangeHandler = numberChangeHandler
    }
    
    @objc func subtract( _ sender: Any) {
        currentNumber -= 1
        numberChangeHandler?(currentNumber)
    }
    
    @objc func add( _ sender: Any) {
        currentNumber += 1
        numberChangeHandler?(currentNumber)
    }
}
