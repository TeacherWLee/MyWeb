//
//  VCEditThings.swift
//  MyThings
//
//  Created by LiWei on 2017/1/10.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditThings: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfCount: UITextField!
    @IBOutlet weak var tfMaxCount: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfType: UITextField!
    @IBOutlet weak var tfDetail: UITextField!
    @IBOutlet weak var tfCategory: UITextField!
    @IBOutlet weak var tfPosition: UITextField!
    @IBOutlet weak var tfOwner: UITextField!
    @IBOutlet weak var tfMarchant: UITextField!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfExpeir: UITextField!
    
    // MARK: data members
    var pvCategory: UIPickerView!               // 类别选择器控件
    var pvPosition: UIPickerView!               // 位置选择器控件
    var pvOwner: UIPickerView!                  // 所有者选择器控件
    var pvMarchant: UIPickerView!               // 商家选择器控件
    var dpDate: UIDatePicker!                   // 日期选择器控件
    var dpExpeir: UIDatePicker!                 // 过期日期选择器控件

    public var isEdit: Bool = true              // 标记状态，状态分为编辑状态和添加状态
    public var m_thing: Thing!                  // 编辑状态传回的实例
    
    var dicCategory: [Int:[Category]]!          // key是Category Collection的ID, value是Category数组
    var arrCC: [CategoryCollection]!            // Category Collection
    var dicPosition: [Int:[Position]]!          // key是Area的ID, value是Position数组
    var arrArea: [Area]!                        // 所有Area
    var arrOwner: [Owner]!                      // 所有Owner
    var arrMarchant: [Marchant]!                // 所有Marchant
    
    var selectedCategory: Category!             // 用户通过pickerView选择的分类
    var selectedPosition: Position!             // 用户通过pickerView选择的地点
    var selectedOwner: Owner!                   // 用户通过pickerView选择的用户
    var selectedMarchant: Marchant!             // 用户通过pickerView选择的商家
    
    let PVHEIGHT = 300                          // pickerView高度
    var arrCategoryDatasource: [Category]!      // pickerView使用的数据源
    var arrPositionDatasource: [Position]!      // pickerView使用的数据源
    
    var toolBarPickerView: UIToolbar!           // pickerView的Toolbar
    
    var oldDate: Date!                          // 记录修改之前的日期
    var oldExpeir: Date!                        // 记录修改之前的过期日期
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        if isEdit {
            self.navigationItem.title = "编辑 \(m_thing.name)"
        } else {
            self.navigationItem.title = "添加物品"
        }
        
        // init picker view
        let framePickerView = CGRect(x: 0, y: Int(self.view.frame.size.height) - PVHEIGHT, width: Int(self.view.frame.size.width), height: PVHEIGHT)
        pvCategory = UIPickerView(frame: framePickerView)
        pvPosition = UIPickerView(frame: framePickerView)
        pvOwner = UIPickerView(frame: framePickerView)
        pvMarchant = UIPickerView(frame: framePickerView)
        // init and set the date picker
        dpDate = UIDatePicker(frame: framePickerView)
        dpExpeir = UIDatePicker(frame: framePickerView)
        
        dpDate.locale = Locale(identifier: "zh")
        dpExpeir.locale = Locale(identifier: "zh")
        dpDate.datePickerMode = .date
        dpExpeir.datePickerMode = .date
        
        // set delegate and datasource
        pvCategory.delegate = self          // pickerView delegate and datasource
        pvCategory.dataSource = self
        pvPosition.delegate = self
        pvPosition.dataSource = self
        pvOwner.delegate = self
        pvOwner.dataSource = self
        pvMarchant.delegate = self
        pvMarchant.dataSource = self
        
        tfCategory.delegate = self          // textField delegate and datasource
        tfPosition.delegate = self
        tfOwner.delegate = self
        tfMarchant.delegate = self
        tfDate.delegate = self
        tfExpeir.delegate = self
        tfType.delegate = self
        tfDetail.delegate = self
        
        // init pickerView toolbar
        toolBarPickerView = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let bbiPVDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerViewDone))
        let bbiFlexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBarPickerView.items = [bbiFlexible, bbiPVDone]
        
        // access db and deal the data
        dealData()
}
    
    // MARK: member functions
    func dealData() {
        // initial dic and array
        arrCC = [CategoryCollection]()
        dicCategory = [Int:[Category]]()
        arrArea = [Area]()
        dicPosition = [Int:[Position]]()
        arrOwner = [Owner]()
        arrMarchant = [Marchant]()
        
        // get and process data
        arrCC = DataProcess.dp.getAllCC()
        arrArea = DataProcess.dp.getAllArea()
        arrOwner = DataProcess.dp.getAllOwner()
        arrMarchant = DataProcess.dp.getAllMarchant()
        
        for item in arrCC {
            dicCategory[item.id] = [Category]()
        }
        for item in arrArea {
            dicPosition[item.id] = [Position]()
        }

        let arrCategory = DataProcess.dp.getAllCategory()
        for item in arrCategory {
            dicCategory[item.cc]?.append(item)
        }
        let arrPosition = DataProcess.dp.getAllPosition()
        for item in arrPosition {
            dicPosition[item.area]?.append(item)
        }
        
        arrCategoryDatasource = dicCategory[arrCC[0].id]
        arrPositionDatasource = dicPosition[arrArea[0].id]
        
        selectedCategory = (dicCategory[arrCC[0].id])?[0]
        selectedPosition = (dicPosition[arrArea[0].id])?[0]
        selectedOwner = arrOwner[0]
        selectedMarchant = arrMarchant[0]
        
        if !isEdit {                        // 添加状态下部分默认值
            tfCategory.text = (dicCategory[arrCC[0].id])?[0].name
            tfPosition.text = (dicPosition[arrArea[0].id])?[0].name
            tfOwner.text = arrOwner[0].name
            tfMarchant.text = arrMarchant[0].name
            
            let dateNow = Date()
            dpDate.date = dateNow
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            tfDate.text = df.string(from: dateNow)
            oldDate = dateNow
            
            var dc = DateComponents()
            dc.year = 1
            
            let calendar = Calendar(identifier: .chinese)
            let dateExpeir = calendar.date(byAdding: dc, to: dateNow)
            dpExpeir.date = dateExpeir!
            tfExpeir.text = df.string(from: dateExpeir!)
            oldExpeir = dateExpeir
        }
        
        if isEdit && m_thing != nil {      // 处理编辑状态的默认值
            tfName.text = m_thing.name
            tfCount.text = String(m_thing.count)
            tfMaxCount.text = String(m_thing.maxcount)
            tfPrice.text = String(m_thing.price)
            tfType.text = m_thing.type
            tfDetail.text = m_thing.detail
            selectedCategory = DataProcess.dp.getCategory(id: m_thing.category)!
            tfCategory.text = selectedCategory.name
            selectedPosition = DataProcess.dp.getPosition(id: m_thing.position)!
            tfPosition.text = selectedPosition.name
            selectedOwner = DataProcess.dp.getOwner(id: m_thing.owner)!
            tfOwner.text = selectedOwner.name
            selectedMarchant = DataProcess.dp.getMarchant(id: m_thing.marchant)!
            tfMarchant.text = selectedMarchant.name
            
            var imgThing = DataProcess.dp.loadImage(img: m_thing.img)         // 处理图片
            if imgThing == nil {
                imgThing = UIImage(named: "default_thing")
            }
            imageView.image = imgThing
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            dpDate.date = m_thing.date
            tfDate.text = df.string(from: m_thing.date)
            oldDate = m_thing.date
            
            dpExpeir.date = m_thing.expeir
            tfExpeir.text = df.string(from: m_thing.expeir)
            oldExpeir = m_thing.expeir
        }
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {   // 列数量
        if pickerView == pvCategory {
            return 2
        } else if pickerView == pvPosition {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {    // 每列的行数
        if pickerView == pvCategory {
            if component == 0 {
                return arrCC.count
            } else {
                return arrCategoryDatasource.count
            }
        } else if pickerView == pvPosition {
            if component == 0 {
                return arrArea.count
            } else {
                return arrPositionDatasource.count
            }
        } else if pickerView == pvOwner {
            return arrOwner.count
        } else {
            return arrMarchant.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {     // 每行的内容
        if pickerView == pvCategory {
            if component == 0 {
                return arrCC[row].name
            } else {
                return arrCategoryDatasource[row].name
            }
        } else if pickerView == pvPosition {
            if component == 0 {
                return arrArea[row].name
            } else {
                return arrPositionDatasource[row].name
            }
        } else if pickerView == pvOwner {
            return arrOwner[row].name
        } else {
            return arrMarchant[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        // 选择某行
        if pickerView == pvCategory {
            if component == 0 {
                arrCategoryDatasource = dicCategory[arrCC[row].id]
                pvCategory.selectRow(0, inComponent: 1, animated: true)
                pvCategory.reloadComponent(1)
                
                if arrCategoryDatasource.count > 0 {
                    selectedCategory = arrCategoryDatasource.first
                    tfCategory.text = selectedCategory.name
                }
            } else {
                selectedCategory = arrCategoryDatasource[row]
                tfCategory.text = selectedCategory.name
            }
        } else if pickerView == pvPosition {
            if component == 0 {
                arrPositionDatasource = dicPosition[arrArea[row].id]
                pvPosition.selectRow(0, inComponent: 1, animated: true)
                pvPosition.reloadComponent(1)
                
                if arrPositionDatasource.count > 0 {
                    selectedPosition = arrPositionDatasource.first
                    tfPosition.text = selectedPosition.name
                }
            } else {
                selectedPosition = arrPositionDatasource[row]
                tfPosition.text = selectedPosition.name
            }
        } else if pickerView == pvOwner {
            selectedOwner = arrOwner[row]
            tfOwner.text = selectedOwner.name
        } else {
            selectedMarchant = arrMarchant[row]
            tfMarchant.text = selectedMarchant.name
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImage: UIImage
        
        if picker.sourceType == .photoLibrary {     // 从图库中选择图片
            selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        } else {        // 从相机中选取图片
            if picker.allowsEditing {       // 选取编辑后的照片
                selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
            } else {
                selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            }
            
            UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)    //保存到相册
        }
        
        imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: textfield delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == tfCategory {
            textField.inputView = pvCategory
            textField.inputAccessoryView = toolBarPickerView
        } else if textField == tfPosition {
            textField.inputView = pvPosition
            textField.inputAccessoryView = toolBarPickerView
        } else if textField == tfOwner {
            textField.inputView = pvOwner
            textField.inputAccessoryView = toolBarPickerView
        } else if textField == tfMarchant {
            textField.inputView = pvMarchant
            textField.inputAccessoryView = toolBarPickerView
        } else if textField == tfDate {
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
            let bbiDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dpDateDone))
            let bbiCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dpDateCancel))
            let bbiFlexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolBar.items = [bbiCancel, bbiFlexible, bbiDone]
            
            textField.inputView = dpDate
            textField.inputAccessoryView = toolBar
        } else if textField == tfExpeir {
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
            let bbiDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dpExpeirDone))
            let bbiCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dpExpeirCancel))
            let bbiFlexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolBar.items = [bbiCancel, bbiFlexible, bbiDone]
            
            textField.inputView = dpExpeir
            textField.inputAccessoryView = toolBar
        } else if textField == tfType || textField == tfDetail {    // 如果是类型或描述，避免键盘遮挡
            UIView.beginAnimations(nil, context: nil)       // 开始动画
            UIView.setAnimationDuration(0.3)                // 设置动画持续时间
            self.view.frame = CGRect(x: 0, y: -150, width: self.view.frame.size.width, height: self.view.frame.size.height)
            UIView.commitAnimations()                       // 结束动画
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == tfType || textField == tfDetail {
            self.view.endEditing(true)
            UIView.beginAnimations(nil, context: nil)       // 开始动画
            UIView.setAnimationDuration(0.3)                // 设置动画持续时间
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            UIView.commitAnimations()                       // 结束动画
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.beginAnimations(nil, context: nil)       // 开始动画
        UIView.setAnimationDuration(0.3)                // 设置动画持续时间
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        UIView.commitAnimations()                       // 结束动画
    }
    
    // MARK: ui actions
    @IBAction func btnDoneAction(_ sender: UIButton) {                      // 点击完成按钮
        // 进行一些输入检测
        if (tfName.text == "") {
            let alertCtrl = UIAlertController(title: "提示", message: "物品名称不能为空", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alertCtrl.addAction(cancelAction)
            present(alertCtrl, animated: true, completion: nil)
            return
        }
        
        var count:Int?
        if tfCount.text != "" {
            count = Int(tfCount.text!)
            if count == nil {
                count = 1
            }
        } else {
            count = 1
        }
        
        var maxCount:Int?
        if tfMaxCount.text != "" {
            maxCount = Int(tfMaxCount.text!)
            if maxCount == nil {
                maxCount = 1
            }
        } else {
            maxCount = 1
        }
        
        var price:Double?
        if tfPrice.text != "" {
            price = Double(tfPrice.text!)
            if price == nil {
                price = 0.0
            }
        } else {
            price = 0.0
        }
        
        // 保存图片
        let img = imageView.image
        var imgPath = ""
        if img != nil {
            imgPath = DataProcess.dp.saveImage(img: img!)
        }

        if isEdit {     // 编辑状态
            // 删除以前的照片
            DataProcess.dp.deleteImage(img: m_thing.img)
            
            let now = Date()
            // 更新数据库
            let thing = Thing(id: m_thing.id, name: tfName.text!, category: selectedCategory.id, position: selectedPosition.id, owner: selectedOwner.id, count: count!, maxcount: maxCount!, date: dpDate.date, expeir: dpExpeir.date, price: price!, img: imgPath, marchant: selectedMarchant.id, type: tfType.text!, detail: tfDetail.text!, state: 0, timestamp: now)
            
            DataProcess.dp.updateThings(thing: thing)
            let vcSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCViewThings
            vcSuper.refresh()
            let vcSuperSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
            if vcSuperSuper is VCAllThings {
                let vc = vcSuperSuper as! VCAllThings
                vc.refresh()
            } else if vcSuperSuper is VCViewCategory {
                let vc = vcSuperSuper as! VCViewCategory
                vc.refresh()
            } else if vcSuperSuper is VCViewPosition {
                let vc = vcSuperSuper as! VCViewPosition
                vc.refresh()
            } else if vcSuperSuper is VCViewOwner {
                let vc = vcSuperSuper as! VCViewOwner
                vc.refresh()
            } else if vcSuperSuper is VCViewMarchant {
                let vc = vcSuperSuper as! VCViewMarchant
                vc.refresh()
            }
        } else {        // 添加状态
            // 保存到数据库
            DataProcess.dp.addThings(name: tfName.text!, category: selectedCategory, position: selectedPosition, owner: selectedOwner, count: count!, maxcount: maxCount!, date: dpDate.date, expeir: dpExpeir.date, price: price!, img: imgPath, marchant: selectedMarchant, type: tfType.text!, detail: tfDetail.text!)
            
            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCAllThings
            vc.refresh()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapGestureSelectImageAction(_ sender: UITapGestureRecognizer) {  // 选择图片的手势识别动作函数
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func pickerViewDone() {
        tfCategory.resignFirstResponder()
        tfPosition.resignFirstResponder()
        tfOwner.resignFirstResponder()
        tfMarchant.resignFirstResponder()
    }
    
    func dpDateDone() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        tfDate.text = df.string(from: dpDate.date)
        oldDate = dpDate.date
        tfDate.resignFirstResponder()
    }
    
    func dpDateCancel() {
        dpDate.date = oldDate
        tfDate.resignFirstResponder()
    }
    
    func dpExpeirDone() {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        tfExpeir.text = df.string(from: dpExpeir.date)
        oldExpeir = dpExpeir.date
        tfExpeir.resignFirstResponder()
    }
    
    func dpExpeirCancel() {
        dpExpeir.date = oldExpeir
        tfExpeir.resignFirstResponder()
    }
    
    @IBAction func btnCameraAction(_ sender: UIButton) {
        // 判断设备是否有摄像头
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
}
