//
//  VCEditCategoryCollection.swift
//  MyThings
//
//  Created by LiWei on 2017/1/9.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditCategoryCollection: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfCCName: UITextField!
    @IBOutlet weak var tfCCDetail: UITextField!
    
    public var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UI Actions
    @IBAction func btnDoneAction(_ sender: UIButton) {
        if tfCCName.text != "" {
            DataProcess.dp.addCC(name: tfCCName.text!, imgPath: "tmp", detail: tfCCDetail.text!)
        }

        self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2].viewDidLoad()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func tapGestureSelectImage(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.delegate = self
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
