//
//  VCEditArea.swift
//  MyThings
//
//  Created by LiWei on 2017/1/10.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditArea: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfDetail: UITextField!
    
    public var isEdit: Bool = false         // 标记状态，状态分为编辑状态和添加状态
    public var m_area: Area!                // 编辑状态传回的实例

    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航控制器
        if isEdit {
            self.navigationItem.title = "编辑区域（\(m_area.name)）"
        } else {
            self.navigationItem.title = "添加区域"
        }
        
        // default value
        if isEdit { // 编辑状态下，一些控件的默认值
            var img = DataProcess.dp.loadImage(img: m_area.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_area")
            }
            imageView.image = img
            
            tfName.text = m_area.name
            tfDetail.text = m_area.detail
        }
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
        
        // 保存图片
        let img = imageView.image
        var imgPath = ""
        if img != nil {
            imgPath = DataProcess.dp.saveImage(img: img!)
        }
        
        if isEdit {     // 编辑状态
            // 删除以前的照片
            DataProcess.dp.deleteImage(img: m_area.img)
            
            // 更新数据库
            let area = Area(id: m_area.id, name: tfName.text!, detail: tfDetail.text!, img: imgPath)
            DataProcess.dp.updateArea(area: area)
            
            // 更新视图
            let vcSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2]
            if vcSuper is VCViewArea {
                let vc = vcSuper as! VCViewArea
                vc.refresh()
                let vcSuperSuper = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3] as! VCSetArea
                vcSuperSuper.refresh()
            } else if vcSuper is VCSetArea {
                let vc = vcSuper as! VCSetArea
                vc.refresh()
            }
        } else {        // 添加状态
            // 保存到数据库
            DataProcess.dp.addArea(name: tfName.text!, img: imgPath, detail: tfDetail.text!)
            
            let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCSetArea
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
