//
//  File.swift
//  AnimateTf
//
//  Created by XL on 2018/10/29.
//  Copyright © 2018 pxl. All rights reserved.
//

import UIKit
import SnapKit

/*用法:
 let tf = XLAnimateTextField.init(placeHolderText: "123")
 tf.clearMode = .whileEditing
 tf.delegate = self
 tf.themeColor = UIColor.red
 view.addSubview(tf)
 
 tf.snp.makeConstraints { (make) in
    make.height.equalTo(tf.heightDefault)
    make.top.left.right.equalToSuperview()
 }
 */


@objc protocol XLAnimateTextFieldDelegate:class {
    @objc optional func XLAnimateTextFieldDidBeginEditing(_ textfield:XLAnimateTextField)
    @objc optional func XLAmateTextFieldDidEndEditing(_ textfield:XLAnimateTextField)
    @objc optional func XLAmateTextFieldValueChanged(_ textfield: XLAnimateTextField)
}

class XLAnimateTextField: UIView, UITextFieldDelegate {

    var heightDefault = CGFloat.init(55) //default height
    var animationTimeToTop = 0.1
    var animationTimeToEnd = 0.3
    
    //some default colors
    var themeColor = UIColor (red: 11.0/255.0, green: 157.0/255.0, blue: 120.0/255.0, alpha: 1.0)
    private let greyColor = UIColor (red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    private let lineColor = UIColor (red: 214.0/255.0, green: 214.0/255.0, blue: 214.0/255.0, alpha: 1.0)
    
    //textfield
    var clearMode = UITextField.ViewMode.never {
        willSet {
            self.textfield.clearButtonMode = newValue
        }
    }
    var text: String {
        get {
            return self.textfield.text ?? ""
        }
    }
    var placeHolder:String {
        get {
            return self.placeHolderText
        }
    }
    weak var delegate:(NSObject & XLAnimateTextFieldDelegate)?
    
    private var phFont:UIFont! // placeholderLabel font
    private var phTopFont:UIFont! // placeholderLabel font when top
    private var tfFont:UIFont!
    private var bottomLineHeight = CGFloat(0.5)
    
    //views
    var textfield:UITextField!
    var bottomLine:UIView!
    private var placeHolderLabel:UILabel!//defalt:top：16,bottom：11
    private var leftView:UIView? = nil
    private var rightView:UIView? = nil
    
    //judge whether placeholderLabel is above.
    var labelOnTop = false
    private var tf_isFirstResponder = false
    
    private var placeHolderText = ""
    
    /*scale size*/
    private var scaleShrink:CGFloat {
        get {
            return CGFloat.init(phTopFont.pointSize/phFont.pointSize)
        }
    }
    private var scaleMagnify:CGFloat {
        get {
            return CGFloat.init(phFont.pointSize/phTopFont.pointSize)
        }
    }
    
    //MARK:init --------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        self.textfield.removeObserver(self, forKeyPath: "text")
    }
    
    convenience init(placeHolderText:String, left:UIView?=nil, right:UIView?=nil) {
        self.init(placeHolderText: placeHolderText,
                  phFont: UIFont.systemFont(ofSize: 16, weight: .thin),
                  phTopFont: UIFont.systemFont(ofSize: 11, weight: .thin),
                  tfFont:UIFont.systemFont(ofSize: 25, weight: .thin),
                  left:left,
                  right:right,
                  bottomLineHeight:0.5)
    }
    
    convenience init(placeHolderText:String, phFont:UIFont, phTopFont:UIFont, tfFont:UIFont, left:UIView?, right:UIView?, bottomLineHeight:CGFloat) {
        self.init(frame: .zero)
        self.config(placeHolderText: placeHolderText, phFont: phFont, phTopFont: phTopFont, tfFont: tfFont, left: left, right: right, bottomLineHeight: bottomLineHeight)
    }
    
    func config(placeHolderText:String, phFont:UIFont, phTopFont:UIFont, tfFont:UIFont, left:UIView?, right:UIView?, bottomLineHeight:CGFloat) {
        self.placeHolderText = placeHolderText
        self.phFont = phFont
        self.phTopFont = phTopFont
        self.tfFont = tfFont
        self.leftView = left
        self.rightView = right
        self.bottomLineHeight = bottomLineHeight
        self.createUI()
        self.layoutUI()
    }
    
    private func createUI() {
        self.placeHolderLabel = UILabel.init()
        self.placeHolderLabel.font = self.phFont
        self.placeHolderLabel.textColor = greyColor
        self.placeHolderLabel.textAlignment = .left
        self.placeHolderLabel.text = placeHolderText
        self.placeHolderLabel.numberOfLines = 1
        self.addSubview(self.placeHolderLabel)
        
        self.textfield = UITextField.init()
        self.textfield.font = self.tfFont
        self.textfield.text = ""
        self.textfield.placeholder = nil
        self.textfield.delegate = self
        if self.leftView != nil {
            self.textfield.leftView = self.leftView!
            self.textfield.leftViewMode = .always
        }
        if self.rightView != nil {
            self.textfield.rightView = rightView!
            self.textfield.rightViewMode = .always
        }
        
        self.textfield.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
        self.textfield.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        
        
        self.addSubview(self.textfield)
        
        self.bottomLine = UIView()
        self.bottomLine.backgroundColor = self.lineColor
        self.addSubview(self.bottomLine)
    }
    
    private func layoutUI() {
        
        self.bottomLine.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(0.5)
        }
        self.textfield.snp.makeConstraints { (make) in
            make.left.equalTo(self.bottomLine).offset(5)
            make.right.equalTo(self.bottomLine).offset(-5)
            make.bottom.equalTo(self.bottomLine).offset(-4)
        }
        
        
        self.placeHolderLabel.snp.makeConstraints { (make) in
            if self.leftView != nil {
                make.left.equalTo(self.textfield).offset(self.leftView!.frame.width)
            } else {
                make.left.equalTo(self.textfield)
            }
            if self.rightView != nil {
                make.right.lessThanOrEqualTo(self.textfield).offset(-self.rightView!.frame.width)
            } else {
                make.right.lessThanOrEqualTo(self.textfield)
            }
            make.bottom.equalTo(self.textfield)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.labelOnTop {
            self.goToBottom()
            self.goToTop()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != nil,
        keyPath! == "text",
        let _ = object as? UITextField else {
            return
        }
        let t =  self.textfield.text
        if t == nil || t! == "" {
            UIView.animate(withDuration: animationTimeToEnd, animations: {
                self.goToBottom()
            }) { (bool) in
                
            }
        } else {
            self.goToTop()
        }
    }
    
    //MARK:textfield delegate -----------------------------
    @objc func textFieldValueChanged(_ textField: UITextField){
        if self.delegate != nil  && self.delegate!.responds(to: #selector(XLAnimateTextFieldDelegate.XLAmateTextFieldValueChanged(_:))) {
            self.delegate!.XLAmateTextFieldValueChanged!(self)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.placeHolderLabel.textColor = themeColor
        self.bottomLine.backgroundColor = themeColor
        if self.tf_isFirstResponder == false && self.labelOnTop == false {
            UIView.animate(withDuration: self.animationTimeToTop, animations: {
                self.goToTop()
            }) { (bool) in
                self.tf_isFirstResponder = true
                textField.becomeFirstResponder()
            }
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.delegate != nil  && self.delegate!.responds(to: #selector(XLAnimateTextFieldDelegate.XLAnimateTextFieldDidBeginEditing(_:))) {
            self.delegate!.XLAnimateTextFieldDidBeginEditing!(self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.delegate != nil) && self.delegate!.responds(to: #selector(XLAnimateTextFieldDelegate.XLAmateTextFieldDidEndEditing(_:))) {
            self.delegate!.XLAmateTextFieldDidEndEditing!(self)
        }
        self.bottomLine.backgroundColor = lineColor
        self.placeHolderLabel.textColor = greyColor
        self.tf_isFirstResponder = false
        
    }
    
    func manually_toTop() {
        self.goToTop()
    }
    
    func manually_toBottom() {
        self.goToBottom()
    }
    
    private func goToTop() {
        if self.labelOnTop == true {
            return
        }
        
        self.placeHolderLabel.transform = self.placeHolderLabel.transform.scaledBy(x: self.scaleShrink, y: self.scaleShrink)
        self.placeHolderLabel.frame.origin.x = 7
        self.placeHolderLabel.frame.origin.y = 3
        self.labelOnTop = true
    }
    
    private func goToBottom() {
        if self.labelOnTop == false {
            return
        }
        
        self.placeHolderLabel.transform = self.placeHolderLabel.transform.scaledBy(x: self.scaleMagnify, y: self.scaleMagnify)
        if self.leftView != nil {
            self.placeHolderLabel.frame.origin.x = 5 + self.leftView!.frame.width
        } else {
            self.placeHolderLabel.frame.origin.x = 5
        }
        self.placeHolderLabel.frame.origin.y = self.frame.height-4-self.getTextFrame(text: self.placeHolderText, font: self.phFont).height
        self.labelOnTop = false
    }
    
    private func getTextFrame(text:String, font:UIFont) -> CGRect {
        let testLabel = UILabel()
        testLabel.text = text
        testLabel.font = font
        testLabel.sizeToFit()
        return testLabel.frame
    }
}





