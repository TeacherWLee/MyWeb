//
//  VCEditCC.swift
//  MyThings
//
//  Created by Li Wei on 2017/1/18.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditCC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RefreshViewDelegate {
    
    // ----------------------------------------------------
    // MARK: data member
    public var delegate: RefreshViewDelegate!           // 修改后，需要刷新内容的视图代理
    private var m_editType: EditType = .EDIT_TYPE_NEW   // 编辑状态
    private var m_inputCC: CategoryCollection!          // 编辑状态传回的实例
    
    private var m_nLayoutX = 0
    private var m_nLayoutY = 0
    private var m_nLayoutW = 0
    private var m_nLayoutH = 0
    
    private var m_nTfOrderY: Int = 0
    
    private var m_imageView: UIImageView!
    private var m_tfName: UITextField!
    private var m_tfDetail: UITextField!
    private var m_tfOrder: UITextField!
    private var m_lblID: UILabel!
    private var m_lblState: UILabel!
    private var m_lblCT: UILabel!
    private var m_lblMT: UILabel!
    private var m_btnDone: UIButton!
    
    
    // ----------------------------------------------------
    // MARK: Initial
    init() {
        m_editType = .EDIT_TYPE_NEW
        super.init(nibName: nil, bundle: nil)
    }
    
    init(cc: CategoryCollection, editType: EditType) {
        m_inputCC = cc
        m_editType = editType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // ----------------------------------------------------
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // ---- data members initial ----
        m_nLayoutX = SAFE_AREA_MARGIN
        m_nLayoutY = NAV_HEIGHT + 15
        m_nLayoutW = Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2
        m_nLayoutH = DEFAULT_HEIGHT
        
        // ---- navigation controller ----
        switch m_editType {
        case .EDIT_TYPE_EDIT:
            self.navigationItem.title = "编辑分类组 \(m_inputCC.name)"
        case .EDIT_TYPE_NEW:
            self.navigationItem.title = "添加分类组"
        case .EDIT_TYPE_VIEW:
            self.navigationItem.title = m_inputCC.name
        }
        
        if m_editType == .EDIT_TYPE_VIEW {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editCC))
        }
        
        // ---- 视图对象构造并页面布局 ----
        layout()
        
        // ---- 数据处理 ----
        loadData()
        
        // ---- keyboard notification ----
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    
    // ----------------------------------------------------
    // MARK: Layout and Data Process
    func layout() {
        // ---- init gesture ----
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureSelectImageAction))
        
        // ---- 背景颜色 ----
        self.view.backgroundColor = UIColor.white
        
        // ---- 图片 ----
//        let lblImage = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
//        m_nLayoutY += m_nLayoutH
//        lblImage.text = "分类组图片："
//        lblImage.textColor = UIColor.darkGray
//        self.view.addSubview(lblImage)
        
        m_imageView = UIImageView(frame: CGRect(x: m_nLayoutX + ((m_nLayoutW - DEFAULT_IMG_SIZE) / 2), y: m_nLayoutY, width: DEFAULT_IMG_SIZE, height: DEFAULT_IMG_SIZE))
        m_nLayoutY = m_nLayoutY + DEFAULT_IMG_SIZE + SEPARATE_HEIGHT
        m_imageView.image = UIImage(named: "default_cc")
        m_imageView.layer.cornerRadius = CORNER_RADIUS
        m_imageView.layer.masksToBounds = true
        if m_editType != .EDIT_TYPE_VIEW {
            m_imageView.isUserInteractionEnabled = true
            m_imageView.addGestureRecognizer(tapGesture)
        }
        self.view.addSubview(m_imageView)
        
        // ---- 名称 ----
        let lblName = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblName.text = "分类组名称："
        lblName.textColor = UIColor.darkGray
        self.view.addSubview(lblName)
        
        m_tfName = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfName.borderStyle = .roundedRect
        m_tfName.returnKeyType = .done
        if m_editType != .EDIT_TYPE_VIEW {m_tfName.clearButtonMode = .whileEditing}
        self.view.addSubview(m_tfName)
        m_tfName.delegate = self
        
        // ---- 分类描述 ----
        let lblDetail = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblDetail.text = "分类组描述："
        lblDetail.textColor = UIColor.darkGray
        self.view.addSubview(lblDetail)
        
        m_tfDetail = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfDetail.borderStyle = .roundedRect
        m_tfDetail.returnKeyType = .done
        if m_editType != .EDIT_TYPE_VIEW {m_tfDetail.clearButtonMode = .whileEditing}
        self.view.addSubview(m_tfDetail)
        m_tfDetail.delegate = self
        
        // ---- 顺序号 ----
        let lblOrder = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nTfOrderY = m_nLayoutY
        m_nLayoutY += m_nLayoutH
        lblOrder.text = "顺序号："
        lblOrder.textColor = UIColor.darkGray
        self.view.addSubview(lblOrder)
        
        m_tfOrder = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfOrder.borderStyle = .roundedRect
        m_tfOrder.returnKeyType = .done
        m_tfOrder.keyboardType = .numberPad
        m_tfOrder.clearsOnBeginEditing = true
        self.view.addSubview(m_tfOrder)
        m_tfOrder.delegate = self
        
        if m_editType == .EDIT_TYPE_VIEW {
            // ---- ID ----
            let lblID = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: Int(WIDTH_4_CHS), height: m_nLayoutH))
            lblID.text = "主键号ID："
            lblID.textColor = UIColor.darkGray
            self.view.addSubview(lblID)
            
            m_lblID = UILabel(frame: CGRect(x: m_nLayoutX + WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW - WIDTH_4_CHS, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
            self.view.addSubview(m_lblID)
            
            // ---- 状态 ----
            let lblState = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            lblState.text = "状        态："
            lblState.textColor = UIColor.darkGray
            self.view.addSubview(lblState)
            
            m_lblState = UILabel(frame: CGRect(x: m_nLayoutX + WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW - WIDTH_4_CHS, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
            self.view.addSubview(m_lblState)
            
            // ---- 创建时间 ----
            let lblCT = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            lblCT.text = "创建时间："
            lblCT.textColor = UIColor.darkGray
            self.view.addSubview(lblCT)
            
            m_lblCT = UILabel(frame: CGRect(x: m_nLayoutX + WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW - WIDTH_4_CHS, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
            self.view.addSubview(m_lblCT)
            
            // ---- 修改时间 ----
            let lblMT = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            lblMT.text = "修改时间："
            lblMT.textColor = UIColor.darkGray
            self.view.addSubview(lblMT)
            
            m_lblMT = UILabel(frame: CGRect(x: m_nLayoutX + WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW - WIDTH_4_CHS, height: m_nLayoutH))
            self.view.addSubview(m_lblMT)
        }
        
        // ---- 完成按钮 ----
        m_btnDone = UIButton(frame: CGRect(x: m_nLayoutX, y: Int((self.navigationController?.view.frame.size.height)!) - SAFE_AREA_MARGIN - m_nLayoutH, width: m_nLayoutW, height: m_nLayoutH))
        m_btnDone.setTitle("完成", for: .normal)
        m_btnDone.setTitleColor(UIColor.darkGray, for: .normal)
        m_btnDone.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        m_btnDone.addTarget(self, action: #selector(btnDoneAction(_:)), for: UIControlEvents.touchDown)
        self.view.addSubview(m_btnDone)
    }
    
    func loadData() {
        if m_editType == .EDIT_TYPE_EDIT || m_editType == .EDIT_TYPE_VIEW { // 编辑状态下，一些空间的默认值
            var img = DP.dp.loadImage(img: m_inputCC.img)                   // 处理图片
            if img == nil { img = UIImage(named: "default_cc") }

            m_imageView.image = img
            m_tfName.text = m_inputCC.name
            m_tfDetail.text = m_inputCC.detail
            m_tfOrder.text = String(m_inputCC.oid)
            
            if m_editType == .EDIT_TYPE_VIEW {
                m_tfName.isEnabled = false
                m_tfDetail.isEnabled = false
                m_tfOrder.isEnabled = false
                m_tfName.borderStyle = .none
                m_tfDetail.borderStyle = .none
                m_tfOrder.borderStyle = .none
                m_lblID.text = "\(m_inputCC.id)"
                m_lblState.text = getStateName(state: m_inputCC.state)
                m_lblCT.text = date2String(date: m_inputCC.createtime, dateFormat: "yyyy-MM-dd HH:mm:ss")
                m_lblMT.text = date2String(date: m_inputCC.modifytime, dateFormat: "yyyy-MM-dd HH:mm:ss")
                m_btnDone.isHidden = true
            }
        }
    }

    
    // ----------------------------------------------------
    // MARK: Textfield Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == m_tfOrder {
            let distance = (self.view.bounds.height - g_dKeyboardHeight) - CGFloat(m_nTfOrderY + DEFAULT_HEIGHT * 2)
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = distance
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        m_tfName.resignFirstResponder()
        m_tfDetail.resignFirstResponder()
        m_tfOrder.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == m_tfOrder {
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = 0
            })
        }
        
        if textField == m_tfName && textField.text == "" {
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.borderWidth = 1
        } else {
            textField.layer.borderWidth = 0
        }
    }
    
    
    // ----------------------------------------------------
    // MARK: UI Actions
    @objc func btnDoneAction(_ sender: UIButton) {          // button actions
        // ---- 进行一些输入检测 ----
        if (m_tfName.text == "") {
            alertTip(vc: self, message: "分类组名称不能为空")
            return
        }
        
        var order = Int(m_tfOrder.text!)
        if order == nil { order = 0 }
        
        // ---- 保存图片 ----
        let img = m_imageView.image
        var imgPath = ""
        if img != nil { imgPath = DP.dp.saveImage(img: img!)! }
        
        if m_editType == .EDIT_TYPE_NEW {
            if DP.dp.addCC(name: m_tfName.text!, imgPath: imgPath, detail: m_tfDetail.text!, oid: order!) != 0 { // 保存到数据库
                tipLabel(view: self.view, strTip: "添加类别组 \(m_tfName.text!) 成功")
            } else {
                tipLabel(view: self.view, strTip: "添加类别组 \(m_tfName.text!) 失败，数据库添加失败")
            }
            if delegate != nil {delegate.refresh(p: nil)}
        } else if m_editType == .EDIT_TYPE_EDIT {
            _ = DP.dp.deleteImage(img: m_inputCC.img) // 删除以前的照片
            
            let cc = CategoryCollection(id: m_inputCC.id, name: m_tfName.text!, detail: m_tfDetail.text!, img: imgPath, oid: order!, state: DataState.STATE_NORMAL.rawValue, createtime: m_inputCC.createtime, modifytime: Date())
            if DP.dp.updateCC(cc: cc) != 0 { // 更新数据库
                tipLabel(view: self.view, strTip: "更新类别组 \(cc.name) 成功")
            } else {
                tipLabel(view: self.view, strTip: "更新类别组 \(cc.name) 失败")
            }
            if delegate != nil {delegate.refresh(p: cc)}
        }

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapGestureSelectImageAction(_ sender: UITapGestureRecognizer) {    // gesture actions
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func editCC() {
        let vc = VCEditCC(cc: m_inputCC, editType: .EDIT_TYPE_EDIT)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        m_imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }

    
    // MARK: keyboard notification
    @objc func keyboardWillShow(aNotification: NSNotification) {
        let userinfo = aNotification.userInfo
        let nsValue = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRec = nsValue.cgRectValue
        g_dKeyboardHeight = keyboardRec.size.height
    }
    

    // ------ RefreshViewDelegate ------
    func refresh(p: Any?) {
        if delegate != nil {delegate.refresh(p: nil)}
        if p != nil {
            m_inputCC = p as! CategoryCollection
            self.navigationItem.title = m_inputCC.name
            loadData()
        }
    }
}
