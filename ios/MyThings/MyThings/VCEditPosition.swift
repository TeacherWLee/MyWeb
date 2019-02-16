//
//  VCEditPosition.swift
//  MyThings
//
//  Created by LiWei on 2017/1/10.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditPosition: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RefreshViewDelegate {
    
    // -----------------------------------------------------------
    // MARK: Data Member
    public var delegate: RefreshViewDelegate!               // 修改后，需要刷新内容的视图代理
    private var m_arrArea: [Area]!
    private var m_selectedArea: Area!
    private var m_editType: EditType = .EDIT_TYPE_NEW       // 编辑状态
    private var m_inputPosition: Position!                  // 编辑状态传回的实例
    
    private var m_nLayoutX = 0
    private var m_nLayoutY = 0
    private var m_nLayoutW = 0
    private var m_nLayoutH = 0

    private var m_nTfDetailY: Int = 0
    private var m_nTfMaxCountY: Int = 0
    private var m_nTfOrderY: Int = 0
    
    private var m_pvArea: UIPickerView!                     // 区域
    private var m_imageView: UIImageView!
    private var m_tfName: UITextField!
    private var m_tfArea: UITextField!
    private var m_tfDetail: UITextField!
    private var m_tfOrder: UITextField!
    private var m_lblID: UILabel!
    private var m_lblState: UILabel!
    private var m_lblCT: UILabel!
    private var m_lblMT: UILabel!
    private var m_btnDone: UIButton!
    private var m_toolBarPickerView: UIToolbar!             // pickerView的Toolbar
    
    
    // -----------------------------------------------------------
    // MARK: Initial
    init() {
        m_editType = .EDIT_TYPE_NEW
        super.init(nibName: nil, bundle: nil)
    }
    
    init(position: Position, editType: EditType) {
        m_inputPosition = position
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
            self.navigationItem.title = "编辑 \(m_inputPosition.name)"
        case .EDIT_TYPE_NEW:
            self.navigationItem.title = "添加存储位置"
        case .EDIT_TYPE_VIEW:
            self.navigationItem.title = m_inputPosition.name
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
        m_pvArea = UIPickerView(frame: CGRect(x: 0, y: Int(self.view.bounds.size.height) - PVHEIGHT, width: Int(self.view.bounds.size.width), height: PVHEIGHT))
        m_pvArea.backgroundColor = UIColor.white
        m_pvArea.delegate = self
        m_pvArea.dataSource = self
        
        // ---- init pickerView toolbar ----
        m_toolBarPickerView = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let bbiPVDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerViewDone))
        let bbiFlexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        m_toolBarPickerView.items = [bbiFlexible, bbiPVDone]
        
        // ---- init gesture ----
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureSelectImageAction))
        
        // ---- 背景颜色 ----
        self.view.backgroundColor = UIColor.white
        
        // ---- 位置图片 ----
//        let lblImage = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
//        m_nLayoutY += m_nLayoutH
//        lblImage.text = "位置图片："
//        lblImage.textColor = UIColor.darkGray
//        self.view.addSubview(lblImage)
        
        m_imageView = UIImageView(frame: CGRect(x: m_nLayoutX + ((m_nLayoutW - DEFAULT_IMG_SIZE) / 2), y: m_nLayoutY, width: DEFAULT_IMG_SIZE, height: DEFAULT_IMG_SIZE))
        m_nLayoutY = m_nLayoutY + DEFAULT_IMG_SIZE + SEPARATE_HEIGHT
        m_imageView.image = UIImage(named: "default_position")
        m_imageView.layer.cornerRadius = CORNER_RADIUS
        m_imageView.layer.masksToBounds = true
        if m_editType != .EDIT_TYPE_VIEW {
            m_imageView.isUserInteractionEnabled = true
            m_imageView.addGestureRecognizer(tapGesture)
        }
        self.view.addSubview(m_imageView)
        
        // ---- 位置名称 ----
        let lblName = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblName.text = "位置名称："
        lblName.textColor = UIColor.darkGray
        self.view.addSubview(lblName)
        
        m_tfName = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfName.borderStyle = .roundedRect
        m_tfName.returnKeyType = .done
        if m_editType != .EDIT_TYPE_VIEW { m_tfName.clearButtonMode = .whileEditing }
        self.view.addSubview(m_tfName)
        m_tfName.delegate = self
        
        // ---- 位置描述 ----
        let lblDetail = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nTfDetailY = m_nLayoutY
        m_nLayoutY += m_nLayoutH
        lblDetail.text = "位置描述："
        lblDetail.textColor = UIColor.darkGray
        self.view.addSubview(lblDetail)
        
        m_tfDetail = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfDetail.borderStyle = .roundedRect
        m_tfDetail.returnKeyType = .done
        if m_editType != .EDIT_TYPE_VIEW { m_tfDetail.clearButtonMode = .whileEditing }
        self.view.addSubview(m_tfDetail)
        m_tfDetail.delegate = self
        
        // ---- 所属区域 ----
        var lblArea: UILabel!
        if m_editType == .EDIT_TYPE_VIEW {
            lblArea = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            m_tfArea = UITextField(frame: CGRect(x: m_nLayoutX+WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW-WIDTH_4_CHS, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        } else {
            lblArea = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            m_tfArea = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        }
        
        lblArea.text = "所属区域："
        lblArea.textColor = UIColor.darkGray
        self.view.addSubview(lblArea)

        m_tfArea.borderStyle = .roundedRect
        m_tfArea.inputView = m_pvArea
        m_tfArea.inputAccessoryView = m_toolBarPickerView
        m_tfArea.returnKeyType = .done
        m_tfArea.tintColor = UIColor.clear            // 隐藏光标
        self.view.addSubview(m_tfArea)
        m_tfArea.delegate = self

        // ---- 顺序号 ----
        var lblOrder: UILabel!
        if m_editType == .EDIT_TYPE_VIEW {
            lblOrder = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: WIDTH_4_CHS, height: m_nLayoutH))
            m_tfOrder = UITextField(frame: CGRect(x: m_nLayoutX+WIDTH_4_CHS, y: m_nLayoutY, width: m_nLayoutW-WIDTH_4_CHS, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        } else {
            lblOrder = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            m_tfOrder = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        }

        m_nTfOrderY = m_nLayoutY
        lblOrder.text = "顺  序  号："
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
        
        m_arrArea = DP.dp.getAreas(state: .STATE_NORMAL) //< 获取全部区域Area
        m_selectedArea = m_arrArea[0]
        m_tfArea.text = m_selectedArea.name
        
        if m_editType == .EDIT_TYPE_EDIT || m_editType == .EDIT_TYPE_VIEW {     // 编辑状态下，一些控件的默认值
            var img = DP.dp.loadImage(img: m_inputPosition.img)
            if img == nil { img = UIImage(named: "default_category") }
            
            m_imageView.image = img
            m_tfName.text = m_inputPosition.name
            m_tfDetail.text = m_inputPosition.detail
            m_tfOrder.text = String(m_inputPosition.oid)

            var areaIndex = 0
            for item in m_arrArea {
                if item.id == m_inputPosition.area {
                    m_selectedArea = item
                    break
                }
                areaIndex += 1
            }
            m_pvArea.selectRow(areaIndex, inComponent: 0, animated: true)
            
            m_tfArea.text = m_selectedArea.name
            
            if m_editType == .EDIT_TYPE_VIEW {
                m_tfName.isEnabled = false
                m_tfArea.isEnabled = false
                m_tfDetail.isEnabled = false
                m_tfOrder.isEnabled = false
                
                m_tfName.borderStyle = .none
                m_tfArea.borderStyle = .none
                m_tfDetail.borderStyle = .none
                m_tfOrder.borderStyle = .none
                m_lblID.text = "\(m_inputPosition.id)"
                m_lblState.text = getStateName(state: m_inputPosition.state)
                m_lblCT.text = date2String(date: m_inputPosition.createtime, dateFormat: "yyyy-MM-dd HH:mm:ss")
                m_lblMT.text = date2String(date: m_inputPosition.modifytime, dateFormat: "yyyy-MM-dd HH:mm:ss")
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
        return m_arrArea.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return m_arrArea[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        m_selectedArea = m_arrArea[row]
        m_tfArea.text = m_selectedArea.name
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
        if textField == m_tfDetail || textField == m_tfOrder {
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
        m_tfArea.resignFirstResponder()
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
            alertTip(vc: self, message: "位置名称不能为空")
            return
        }
        
        var order: Int? = Int(m_tfOrder.text!)
        if order == nil { order = 0 }
        
        // ---- 保存图片 ----
        let img = m_imageView.image
        var imgPath = ""
        if img != nil { imgPath = DP.dp.saveImage(img: img!)! }
        
        if m_editType == .EDIT_TYPE_NEW {        // 添加状态
            if DP.dp.addPosition(name: m_tfName.text!, area: m_selectedArea, img: imgPath, detail: m_tfDetail.text!, oid: order!) != 0 {
                tipLabel(view: self.view, strTip: "添加位置 \(m_tfName.text!) 成功")
                if delegate != nil {delegate.refresh(p: nil)}
            } else {
                tipLabel(view: self.view, strTip: "添加位置 \(m_tfName.text!) 失败，数据库添加失败")
            }
        } else if m_editType == .EDIT_TYPE_EDIT {     // 编辑状态
            _ = DP.dp.deleteImage(img: m_inputPosition.img) // 删除以前的照片

            let position = Position(id: m_inputPosition.id, name: m_tfName.text!, area: m_selectedArea.id, img: imgPath, detail: m_tfDetail.text!, oid: order!, state: DataState.STATE_NORMAL.rawValue, createtime: m_inputPosition.createtime, modifytime: Date())
            if DP.dp.updatePosition(position: position) != 0 { // 更新数据库
                tipLabel(view: self.view, strTip: "更新位置 \(position.name) 成功")
            } else {
                tipLabel(view: self.view, strTip: "更新位置 \(position.name) 失败")
            }
            
            if delegate != nil {delegate.refresh(p: position)}
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // ------ RefreshViewDelegate ------
    func refresh(p: Any?) {
        if delegate != nil {delegate.refresh(p: nil)}
        if p != nil {
            m_inputPosition = p as! Position
            self.navigationItem.title = m_inputPosition.name
            loadData()
        }
    }
}
