//
//  VCEditMarchant.swift
//  MyThings
//
//  Created by LiWei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditMarchant: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfDetail: UITextField!
    
    // MARK: data member
    var isEdit: Bool = false         // 标记状态，状态分为编辑状态和添加状态
    public var m_marchant: Marchant!    // 编辑状态传回的实例
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航控制器
        if isEdit {
            self.navigationItem.title = "编辑商家（\(m_marchant.name)）"
        } else {
            self.navigationItem.title = "添加商家"
        }
        
        // default value
        if isEdit { // 编辑状态下，一些控件的默认值
            var img = DataProcess.dp.loadImage(img: m_marchant.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_marchant")
            }
            imageView.image = img
            
            tfName.text = m_marchant.name
            tfDetail.text = m_marchant.detail
        }
    }
    
    // MARK: ui actions
    @IBAction func btnDoneAction(_ sender: UIButton) {
        // 进行一些输入检测
        if (tfName.text == "") {
            let alertCtrl = UIAlertController(title: "提示", message: "商家名称不能为空", preferredStyle: .alert)
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
            DataProcess.dp.deleteImage(img: m_marchant.img)
            
            // 更新数据库
            let marchant = Marchant(id: m_marchant.id, name: tfName.text!, img: imgPath, detail: tfDetail.text!)
            DataProcess.dp.updateMarchant(marchant: marchant)
            
            // 更新视图
            let vcSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
            if vcSuper is VCViewMarchant {
                let vc = vcSuper as! VCViewMarchant
                vc.refresh()
                let vcSuperSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! VCSetMarchant
                vcSuperSuper.refresh()
            } else if vcSuper is VCSetMarchant {
                let vc = vcSuper as! VCSetMarchant
                vc.refresh()
            }
        } else {        // 添加状态
            // 保存到数据库
            DataProcess.dp.addMarchant(name: tfName.text!, img: imgPath, detail: tfDetail.text!)
            
            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCSetMarchant
            vc.refresh()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // tap gesture action
    @IBAction func tapGestureSelectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
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
