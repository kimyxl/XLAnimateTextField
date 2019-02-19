

###### Usage

```
用法:
 let tf = XLAnimateTextField.init(placeHolderText: "123")
 tf.clearMode = .whileEditing
 tf.delegate = self
 tf.themeColor = UIColor.red
 view.addSubview(tf)
 
 tf.snp.makeConstraints { (make) in
    make.height.equalTo(tf.heightDefault)
    make.top.left.right.equalToSuperview()
 }
 注：外部应避免调用layoutIfNeeded

```

![image](https://github.com/kimyxl/XLAnimateTextField/blob/master/images/XLAnimateTextFieldGIF.gif)
