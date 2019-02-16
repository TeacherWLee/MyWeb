//
//  VCEditPosition.swift
//  MyThings
//
//  Created by LiWei on 2017/1/10.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditPosition: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfDetail: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tfOrder: UITextField!
    
    // MARK: data member
    var m_arrArea: [Area]!
    var selectedArea: Area!
    public var isEdit: Bool = true              // 标记状态，状态分为编辑状态和添加状态
    public var m_position: Position!            // 编辑状态传回的实例

    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        if isEdit {
            self.navigationItem.title = "编辑 \(m_position.name)"
        } else {
            self.navigationItem.title = "添加位置"
        }

        m_arrArea = DataProcess.dp.getAllArea()
        
        // pickerView delegate and datasource
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // default value
        if isEdit {     // 编辑状态下，一些控件的默认值
            var img = DataProcess.dp.loadImage(img: m_position.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_position")
            }
            imageView.image = img
            
            tfName.text = m_position.name
            tfDetail.text = m_position.detail
            tfOrder.text = String(m_position.oid)
            
            var areaIndex = 0
            for item in m_arrArea {
                if item.id == m_position.area {
                    selectedArea = item
                    break
                }
                areaIndex += 1
            }
            
            pickerView.selectRow(areaIndex, inComponent: 0, animated: true)
        }
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {   // pickerView 列数
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {    // puckerView 行数
        return m_arrArea.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {     // pickerView每行内容
        return m_arrArea[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        // 选中pickerView某一行
        selectedArea = m_arrArea[row]
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: ui actions
    @IBAction func btnDoneAction(_ sender: UIButton) {
        // 进行一些输入检测
        if (tfName.text == "") {
            let alertCtrl = UIAlertController(title: "提示", message: "物品名称不能为空", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alertCtrl.addAction(cancelAction)
            present(alertCtrl, animated: true, completion: nil)
            return
        }
        
        var order: Int?
        if tfOrder.text != "" {
            order = Int(tfOrder.text!)
            if order == nil {
                order = 0
            }
        } else {
            order = 0
        }
        
        // 保存图片
        let img = imageView.image
        var imgPath = ""
        if img != nil {
            imgPath = DataProcess.dp.saveImage(img: img!)
        }
        
        if isEdit {     // 编辑状态
            // 删除以前的照片
            DataProcess.dp.deleteImage(img: m_position.img)

            // 更新数据库
            let position = Position(id: m_position.id, name: tfName.text!, area: selectedArea.id, img: imgPath, detail: tfDetail.text!, oid: order!)
            DataProcess.dp.updatePosition(position: position)
            
            // 更新视图
            let vcSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
            if vcSuper is VCViewPosition {
                let vc = vcSuper as! VCViewPosition
                vc.refresh()
                let vcSuperSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! VCPosition
                vcSuperSuper.refresh()
            } else if vcSuper is VCPosition {
                let vc = vcSuper as! VCPosition
                vc.refresh()
            }
        } else {        // 添加状态
            // 保存到数据库
            DataProcess.dp.addPosition(name: tfName.text!, area: selectedArea, img: imgPath, detail: tfDetail.text!, oid: order!)
            
            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCPosition
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
}
