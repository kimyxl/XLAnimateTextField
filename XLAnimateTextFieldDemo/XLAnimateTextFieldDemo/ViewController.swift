//
//  ViewController.swift
//  XLAnimateTextFieldDemo
//
//  Created by xiaolei on 2019/2/19.
//  Copyright © 2019 xiaolei. All rights reserved.
//

import UIKit

class ViewController: UIViewController, XLAnimateTextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let accountTf = XLAnimateTextField.init(placeHolderText: "account")
        accountTf.clearMode = .whileEditing
        accountTf.delegate = self
        accountTf.themeColor = UIColor.red
        view.addSubview(accountTf)
        
        accountTf.snp.makeConstraints { (make) in
            make.height.equalTo(accountTf.heightDefault)
            make.top.equalToSuperview().offset(150)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
        }
        
        
        let passwordTf = XLAnimateTextField.init(placeHolderText: "password")
        passwordTf.delegate = self
        view.addSubview(passwordTf)
        
        passwordTf.snp.makeConstraints { (make) in
            make.height.equalTo(accountTf.heightDefault)
            make.top.equalTo(accountTf.snp.bottom).offset(25)
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
        }
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

