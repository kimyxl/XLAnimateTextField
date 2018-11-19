Usage

let tf = XLAnimateTextField.init(placeHolderText: "123")\n
tf.clearMode = .whileEditing\n
tf.delegate = self\n
tf.themeColor = UIColor.red\n
view.addSubview(tf)\n

tf.snp.makeConstraints { (make) in\n
make.height.equalTo(tf.heightDefault)\n
make.top.left.right.equalToSuperview()\n
}
