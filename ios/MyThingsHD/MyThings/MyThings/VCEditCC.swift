//
//  VCEditCC.swift
//  MyThings
//
//  Created by Li Wei on 2017/1/18.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditCC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfCCName: UITextField!
    @IBOutlet weak var tfCCDetail: UITextField!

    // MARK: data member
    public var isEdit: Bool = false                 // 标记状态，状态分为编辑状态和添加状态
    public var m_CC: CategoryCollection!            // 编辑状态传回的实例
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        if isEdit {
            self.navigationItem.title = "编辑分类组 （\(m_CC.name)）"
        } else {
            self.navigationItem.title = "添加分类组"
        }
        
        // default value
        if isEdit { // 编辑状态下，一些控件的默认值
            var img = DataProcess.dp.loadImage(img: m_CC.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_cc")
            }
            imageView.image = img
            
            tfCCName.text = m_CC.name
            tfCCDetail.text = m_CC.detail
        }
    }
    
    // MARK: UI Actions
    @IBAction func btnDoneAction(_ sender: UIButton) {
        // 进行一些输入检测
        if (tfCCName.text == "") {
            let alertCtrl = UIAlertController(title: "提示", message: "物品名称不能为空", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alertCtrl.addAction(cancelAction)
            present(alertCtrl, animated: true, completion: nil)
            return
        }
        
        // 保存图片
        let img = imageView.image
        var imgPath = ""
        if img != nil {
            imgPath = DataProcess.dp.saveImage(img: img!)
        }
        
        if isEdit {     // 编辑状态
            // 删除以前的照片
            DataProcess.dp.deleteImage(img: m_CC.img)
            
            // 更新数据库
            let cc = CategoryCollection(id: m_CC.id, name: tfCCName.text!, detail: tfCCDetail.text!, img: imgPath)
            DataProcess.dp.updateCC(cc: cc)
            
            // 更新视图
            let vcSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
            if vcSuper is VCViewCC {
                let vc = vcSuper as! VCViewCC
                vc.refresh()
                let vcSuperSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! VCSetCC
                vcSuperSuper.refresh()
            } else if vcSuper is VCSetCC {
                let vc = vcSuper as! VCSetCC
                vc.refresh()
            }
        } else {        // 添加状态
            // 保存到数据库
            DataProcess.dp.addCC(name: tfCCName.text!, imgPath: imgPath, detail: tfCCDetail.text!)
            
            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCSetCC
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
