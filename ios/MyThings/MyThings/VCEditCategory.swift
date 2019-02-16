//
//  VCEditCategory.swift
//  MyThings
//
//  Created by LiWei on 2017/1/9.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditCategory: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RefreshViewDelegate {
    
    // -----------------------------------------------------------
    // MARK: Data Membe
    public var delegate: RefreshViewDelegate!                   // 修改后，需要刷新内容的视图代理
    private var m_arrCC: [CategoryCollection]!
    private var m_selectedCC: CategoryCollection!
    private var m_editType: EditType = .EDIT_TYPE_NEW           // 编辑状态
    private var m_inputCategory: Category!                      // 编辑状态传回的实例
    
    private var m_nLayoutX = 0
    private var m_nLayoutY = 0
    private var m_nLayoutW = 0
    private var m_nLayoutH = 0
    
    private var m_nTfDetailY: Int = 0
    private var m_nTfMaxCountY: Int = 0
    private var m_nTfOrderY: Int = 0
    
    private var m_pvCC: UIPickerView!                     // 分类组选择器
    private var m_imageView: UIImageView!
    private var m_tfName: UITextField!
    private var m_tfCC: UITextField!
    private var m_tfDetail: UITextField!
    private var m_tfMaxCount: UITextField!
    private var m_tfOrder: UITextField!
    private var m_lblID: UILabel!
    private var m_lblState: UILabel!
    private var m_lblCT: UILabel!
    private var m_lblMT: UILabel!
    private var m_btnDone: UIButton!
    private var m_toolBarPickerView: UIToolbar!                 // pickerView的Toolbar
    
    
    // -----------------------------------------------------------
    // MARK: Initial
    init() {
        m_editType = .EDIT_TYPE_NEW
        super.init(nibName: nil, bundle: nil)
    }
    
    init(category: Category, editType: EditType) {
        m_inputCategory = category
        m_editType = editType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // -----------------------------------------------------------
    // MARK: App Delegate
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
            self.navigationItem.title = "编辑 \(m_inputCategory.name)"
        case .EDIT_TYPE_NEW:
            self.navigationItem.title = "添加物品分类"
        case .EDIT_TYPE_VIEW:
            self.navigationItem.title = m_inputCategory.name
        }
        
        // ---- 视图对象构造并页面布局 ----
        layout()
        
        // ---- 数据处理 ----
        loadData()
        
        // ---- keyboard notification ----
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    
    // -----------------------------------------------------------
    // MARK: Layout and Data Process
    func layout() {
        // ---- pickerView and delegate ----
        m_pvCC = UIPickerView(frame: CGRect(x: 0, y: Int(self.view.bounds.size.height) - PVHEIGHT, width: Int(self.view.bounds.size.width), height: PVHEIGHT))
        m_pvCC.backgroundColor = UIColor.white
        m_pvCC.delegate = self
        m_pvCC.dataSource = self
        
        // ---- init pickerView toolbar ----
        m_toolBarPickerView = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let bbiPVDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerViewDone))
        let bbiFlexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        m_toolBarPickerView.items = [bbiFlexible, bbiPVDone]
        
        // ---- init gesture ----
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureSelectImageAction))
        
        // ---- 背景颜色 ----
        self.view.backgroundColor = UIColor.white
        
        // ---- 分类图片 ----
//        let lblImage = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
//        m_nLayoutY += m_nLayoutH
//        lblImage.text = "分类图片："
//        lblImage.textColor = UIColor.darkGray
//        self.view.addSubview(lblImage)
        
        m_imageView = UIImageView(frame: CGRect(x: m_nLayoutX + ((m_nLayoutW - DEFAULT_IMG_SIZE) / 2), y: m_nLayoutY, width: DEFAULT_IMG_SIZE, height: DEFAULT_IMG_SIZE))
        m_nLayoutY = m_nLayoutY + DEFAULT_IMG_SIZE + SEPARATE_HEIGHT
        m_imageView.image = UIImage(named: "default_category")
        m_imageView.layer.cornerRadius = CORNER_RADIUS
        m_imageView.layer.masksToBounds = true
        if m_editType != .EDIT_TYPE_VIEW {
            m_imageView.isUserInteractionEnabled = true
            m_imageView.addGestureRecognizer(tapGesture)
        }
        self.view.addSubview(m_imageView)
        
        // ---- 分类名称 ----
        let lblName = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblName.text = "分类名称："
        lblName.textColor = UIColor.darkGray
        self.view.addSubview(lblName)
        
        m_tfName = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfName.borderStyle = .roundedRect
        m_tfName.returnKeyType = .done
        if m_editType != .EDIT_TYPE_VIEW { m_tfName.clearButtonMode = .whileEditing }
        self.view.addSubview(m_tfName)
        m_tfName.delegate = self
        
        // ---- 分类描述 ----
        let lblDetail = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nTfDetailY = m_nLayoutY
        m_nLayoutY += m_nLayoutH
        lblDetail.text = "分类描述："
        lblDetail.textColor = UIColor.darkGray
        self.view.addSubview(lblDetail)
        
        m_tfDetail = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfDetail.borderStyle = .roundedRect
        m_tfDetail.returnKeyType = .done
        if m_editType != .EDIT_TYPE_VIEW { m_tfDetail.clearButtonMode = .whileEditing }
        self.view.addSubview(m_tfDetail)
        m_tfDetail.delegate = self
        
        // ---- 所属分类组 ----
        var lblCC: UILabel!
        if m_editType == .EDIT_TYPE_VIEW {
            lblCC = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            m_tfCC = UITextField(frame: CGRect(x: m_nLayoutX+WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW-WIDTH_4_CHS, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        } else {
            lblCC = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            m_tfCC = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        }

        lblCC.text = "所属类组："
        lblCC.textColor = UIColor.darkGray
        self.view.addSubview(lblCC)

        m_tfCC.borderStyle = .roundedRect
        m_tfCC.inputView = m_pvCC
        m_tfCC.inputAccessoryView = m_toolBarPickerView
        m_tfCC.returnKeyType = .done
        m_tfCC.tintColor = UIColor.clear            // 隐藏光标
        self.view.addSubview(m_tfCC)
        m_tfCC.delegate = self
        
        
        // ---- 本类别最大物品数量 ----
        var lblMaxCount: UILabel!
        if m_editType == .EDIT_TYPE_VIEW {
            lblMaxCount = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            m_tfMaxCount = UITextField(frame: CGRect(x: m_nLayoutX+WIDTH_4_CHS, y: m_nLayoutY, width: 50, height: m_nLayoutH))
            lblMaxCount.text = "最大数量："
        } else {
            lblMaxCount = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nTfMaxCountY = m_nLayoutY
            m_nLayoutY += m_nLayoutH
            lblMaxCount.text = "最大物品数量（0代表不受限制）："
            m_tfMaxCount = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        }
        
        lblMaxCount.textColor = UIColor.darkGray
        self.view.addSubview(lblMaxCount)
        
        m_tfMaxCount.borderStyle = .roundedRect
        m_tfMaxCount.returnKeyType = .done
        m_tfMaxCount.keyboardType = .numberPad
        m_tfMaxCount.text = "1"
        self.view.addSubview(m_tfMaxCount)
        m_tfMaxCount.delegate = self
        
        // ---- 顺序号 ----
        var lblOrder: UILabel!
        if m_editType == .EDIT_TYPE_VIEW {
            lblOrder = UILabel(frame: CGRect(x: Int(self.view.bounds.size.width/2), y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            m_tfOrder = UITextField(frame: CGRect(x: Int(self.view.bounds.size.width/2)+70, y: m_nLayoutY, width: 50, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        } else {
            lblOrder = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nTfOrderY = m_nLayoutY
            m_nLayoutY += m_nLayoutH
            m_tfOrder = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        }
        
        lblOrder.text = "顺序号："
        lblOrder.textColor = UIColor.darkGray
        self.view.addSubview(lblOrder)
        
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
        
        // ----- 完成按钮 ----
        m_btnDone = UIButton(frame: CGRect(x: m_nLayoutX, y: Int((self.navigationController?.view.frame.size.height)!) - SAFE_AREA_MARGIN - m_nLayoutH, width: m_nLayoutW, height: m_nLayoutH))
        m_btnDone.setTitle("完成", for: .normal)
        m_btnDone.setTitleColor(UIColor.darkGray, for: .normal)
        m_btnDone.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        m_btnDone.addTarget(self, action: #selector(btnDoneAction(_:)), for: UIControlEvents.touchDown)
        self.view.addSubview(m_btnDone)
    }
    
    func loadData() {
        m_arrCC = DP.dp.getCCs(state: .STATE_NORMAL)
        m_selectedCC = m_arrCC[0]
        m_tfCC.text = m_selectedCC.name
        
        if m_editType == .EDIT_TYPE_EDIT || m_editType == .EDIT_TYPE_VIEW {     // 编辑状态下，一些空间的默认值
            var img = DP.dp.loadImage(img: m_inputCategory.img)                 // 处理图片
            if img == nil { img = UIImage(named: "default_category") }
            
            m_imageView.image = img
            m_tfName.text = m_inputCategory.name
            m_tfDetail.text = m_inputCategory.detail
            m_tfMaxCount.text = String(m_inputCategory.maxcount)
            m_tfOrder.text = String(m_inputCategory.oid)
            
            var ccIndex = 0
            for item in m_arrCC {
                if item.id == m_inputCategory.cc {
                    m_selectedCC = item
                    break
                }
                ccIndex += 1
            }
            m_pvCC.selectRow(ccIndex, inComponent: 0, animated: true)
            
            m_tfCC.text = m_selectedCC.name
            
            if m_editType == .EDIT_TYPE_VIEW {
                m_tfName.isEnabled = false
                m_tfCC.isEnabled = false
                m_tfDetail.isEnabled = false
                m_tfMaxCount.isEnabled = false
                m_tfOrder.isEnabled = false
                
                m_tfName.borderStyle = .none
                m_tfCC.borderStyle = .none
                m_tfDetail.borderStyle = .none
                m_tfMaxCount.borderStyle = .none
                m_tfOrder.borderStyle = .none
                m_lblID.text = "\(m_inputCategory.id)"
                m_lblState.text = getStateName(state: m_inputCategory.state)
                m_lblCT.text = date2String(date: m_inputCategory.createtime, dateFormat: "yyyy-MM-dd HH:mm:ss")
                m_lblMT.text = date2String(date: m_inputCategory.modifytime, dateFormat: "yyyy-MM-dd HH:mm:ss")
                m_btnDone.isHidden = true
            }
        }
    }
    
    
    // -----------------------------------------------------------
    // MARK: PickerView Delegate
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
        m_selectedCC = m_arrCC[row]
        m_tfCC.text = m_selectedCC.name
    }
    
    
    // -----------------------------------------------------------
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        m_imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    
    // -----------------------------------------------------------
    // MARK: keyboard notification
    @objc func keyboardWillShow(aNotification: NSNotification) {
        let userinfo = aNotification.userInfo
        let nsValue = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRec = nsValue.cgRectValue
        g_dKeyboardHeight = keyboardRec.size.height
    }
    
    
    // -----------------------------------------------------------
    // MARK: Textfield Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == m_tfDetail {
            let distance = (self.view.bounds.height - g_dKeyboardHeight) - CGFloat(m_nTfDetailY + DEFAULT_HEIGHT * 2)
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = distance
            })
        }
        
        if textField == m_tfMaxCount {
            let distance = (self.view.bounds.height - g_dKeyboardHeight) - CGFloat(m_nTfMaxCountY + DEFAULT_HEIGHT * 2)
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = distance
            })
        }
        
        if textField == m_tfOrder {
            let distance = (self.view.bounds.height - g_dKeyboardHeight) - CGFloat(m_nTfOrderY + DEFAULT_HEIGHT * 2)
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = distance
            })
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == m_tfDetail || textField == m_tfMaxCount || textField == m_tfOrder {
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
    
    
    // -----------------------------------------------------------
    // MARK: Toolbar functions
    @objc func pickerViewDone() {
        m_tfCC.resignFirstResponder()
    }
    
    
    // -----------------------------------------------------------
    // MARK: Gesture Action
    @objc func tapGestureSelectImageAction(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    // -----------------------------------------------------------
    // MARK: UI Actions
    @objc func btnDoneAction(_ sender: UIButton) {
        // ---- 进行一些输入检测 ----
        if (m_tfName.text == "") {
            alertTip(vc: self, message: "物品分类名称不能为空")
            return
        }
        
        var maxCount:Int? = Int(m_tfMaxCount.text!)
        if maxCount == nil { maxCount = 0 }
        
        var order: Int? = Int(m_tfOrder.text!)
        if order == nil { order = 0 }
        
        // 保存图片
        let img = m_imageView.image
        var imgPath = ""
        if img != nil { imgPath = DP.dp.saveImage(img: img!)! }
        
        if m_editType == .EDIT_TYPE_NEW {        // 添加状态
            // 保存到数据库
            if DP.dp.addCategory(name: m_tfName.text!, cc: m_selectedCC, img: imgPath, detail: m_tfDetail.text!, maxcount: maxCount!, oid: order!) != 0 {
                tipLabel(view: self.view, strTip: "添加分类 \(m_tfName.text!) 成功")
                if delegate != nil {delegate.refresh(p: nil)}
            } else {
                tipLabel(view: self.view, strTip: "添加分类 \(m_tfName.text!) 失败")
            }
        } else if m_editType == .EDIT_TYPE_EDIT {     // 编辑状态
            _ = DP.dp.deleteImage(img: m_inputCategory.img)
            
            // 更新数据库
            let category = Category(id: m_inputCategory.id, name: m_tfName.text!, cc: m_selectedCC.id, img: imgPath, detail: m_tfDetail.text!, maxcount: maxCount!, oid: order!, state: DataState.STATE_NORMAL.rawValue, createtime: m_inputCategory.createtime, modifytime: Date())
            if DP.dp.updateCategory(category: category) != 0 {
                tipLabel(view: self.view, strTip: "更新分类 \(m_tfName.text!) 成功")
            } else {
                tipLabel(view: self.view, strTip: "更新分类 \(m_tfName.text!) 失败")
            }

            if delegate != nil {delegate.refresh(p: category)}
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // ------ RefreshViewDelegate ------
    func refresh(p: Any?) {
        if delegate != nil {delegate.refresh(p: nil)}
        if p != nil {
            m_inputCategory = p as! Category
            self.navigationItem.title = m_inputCategory.name
            loadData()
        }
    }
}
