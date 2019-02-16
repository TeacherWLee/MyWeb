//
//  VCEditCategory.swift
//  MyThings
//
//  Created by LiWei on 2017/1/9.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditCategory: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfCategoryName: UITextField!
    @IBOutlet weak var tfCategoryDetail: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var tfMaxcount: UITextField!
    @IBOutlet weak var tfOrder: UITextField!
    
    // MARK: data member
    var m_arrCC: [CategoryCollection]!
    var selectedCC: CategoryCollection!
    public var isEdit: Bool = true                 // 标记状态，状态分为编辑状态和添加状态
    public var m_category: Category!                // 编辑状态传回的实例
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        if isEdit {
            self.navigationItem.title = "编辑 \(m_category.name)"
        } else {
            self.navigationItem.title = "添加分类"
        }
        
        m_arrCC = DataProcess.dp.getAllCC()

        // pickerView delegate and datasource
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // default value
        if isEdit {     // 编辑状态下，一些空间的默认值
            var img = DataProcess.dp.loadImage(img: m_category.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_category")
            }
            imageView.image = img
            
            tfCategoryName.text = m_category.name
            tfCategoryDetail.text = m_category.detail
            tfMaxcount.text = String(m_category.maxcount)
            tfOrder.text = String(m_category.oid)
            
            var ccIndex = 0
            for item in m_arrCC {
                if item.id == m_category.cc {
                    selectedCC = item
                    break
                }
                ccIndex += 1
            }
            
            pickerView.selectRow(ccIndex, inComponent: 0, animated: true)
        }
    }
    
    // MARK: PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return m_arrCC.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return m_arrCC[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCC = m_arrCC[row]
    }
    
    // MARK: UI Actions
    @IBAction func btnDoneAction(_ sender: UIButton) {
        // 进行一些输入检测
        if (tfCategoryName.text == "") {
            let alertCtrl = UIAlertController(title: "提示", message: "分类名称不能为空", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alertCtrl.addAction(cancelAction)
            present(alertCtrl, animated: true, completion: nil)
            return
        }

        var maxCount:Int?
        if tfMaxcount.text != "" {
            maxCount = Int(tfMaxcount.text!)
            if maxCount == nil {
                maxCount = 1
            }
        } else {
            maxCount = 1
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
            DataProcess.dp.deleteImage(img: m_category.img)
            
            // 更新数据库
            let category = Category(id: m_category.id, name: tfCategoryName.text!, cc: selectedCC.id, img: imgPath, detail: tfCategoryDetail.text!, maxcount: maxCount!, oid: order!)
            DataProcess.dp.updateCategory(category: category)
            
            // 更新视图
            let vcSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
            if vcSuper is VCViewCategory {
                let vc = vcSuper as! VCViewCategory
                vc.refresh()
                let vcSuperSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! VCCategory
                vcSuperSuper.refresh()
            } else if vcSuper is VCCategory {
                let vc = vcSuper as! VCCategory
                vc.refresh()
            }
        } else {        // 添加状态
            // 保存到数据库
            DataProcess.dp.addCategory(name: tfCategoryName.text!, cc: selectedCC, img: imgPath, detail: tfCategoryDetail.text!, maxcount: maxCount!, oid: order!)
            
            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCCategory
            vc.refresh()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapGestureSelectImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
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
}
