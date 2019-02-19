Usage

let tf = XLAnimateTextField.init(placeHolderText: "123")
tf.clearMode = .whileEditing
tf.delegate = self
tf.themeColor = UIColor.red
view.addSubview(tf)\n

tf.snp.makeConstraints { (make) in
make.height.equalTo(tf.heightDefault)
make.top.left.right.equalToSuperview()\n
}


###### Usage

![image](https://github.com/kimyxl/XLAnimateTextField/blob/master/images/XLAnimateTextFieldGIF.gif)
