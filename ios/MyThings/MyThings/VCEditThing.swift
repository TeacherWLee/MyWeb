//
//  VCEditThings.swift
//  MyThings
//
//  Created by LiWei on 2017/1/10.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCEditThing: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, RefreshViewDelegate {
    
    // --------------------------------------------------------------------
    // MARK: data members
    
    // ------ UI Objectives ------
    public var delegate: RefreshViewDelegate?
    
    private var m_scrollView: UIScrollView!
    private var m_imageView: UIImageView!
    private var m_tfName: UITextField!
    private var m_tfCategory: UITextField!
    private var m_tfPosition: UITextField!
    private var m_tfOwner: UITextField!
    private var m_tfPrice: UITextField!
    private var m_tfMarchant: UITextField!
    private var m_tfPurchaseDate: UITextField!
    private var m_tfExpeirDate: UITextField!
    private var m_tfType: UITextField!
    private var m_tfDetail: UITextField!
    private var m_tfCount: UITextField!
    private var m_tfMaxCount: UITextField!
    private var m_lblID: UILabel!
    private var m_lblState: UILabel!
    private var m_lblCT: UILabel!
    private var m_lblMT: UILabel!
    private var m_btnDone: UIButton!
    private var m_toolBarPickerView: UIToolbar!           // pickerView的Toolbar
    private var m_toolBarPurchaseDate: UIToolbar!         // pickerView的Toolbar
    private var m_toolBarExpeirDate: UIToolbar!
    private var m_popMenu: SwiftPopMenu!                  // 弹出菜单
    private var m_viewShowImage: UIView!                  // 显示大图片的视图
    private var m_imgViewShowImg: UIImageView!            // 显示大图片的图片视图
    private var m_imgViewPositionThumb: UIImageView!      // 存储位置缩略图
    private var m_imgViewOwnerThumb: UIImageView!         // 拥有者缩略图
    private var m_imgViewMarchantThumb: UIImageView!      // 商家缩略图
    
    // ------ pickerView ------
    private var m_pvCategory: UIPickerView!               // 类别选择器控件
    private var m_pvPosition: UIPickerView!               // 位置选择器控件
    private var m_pvOwner: UIPickerView!                  // 所有者选择器控件
    private var m_pvMarchant: UIPickerView!               // 商家选择器控件
    private var m_dpPurchaseDate: UIDatePicker!           // 日期选择器控件
    private var m_dpExpeirDate: UIDatePicker!             // 过期日期选择器控件
    
    // ------ ui position ------
    private var m_nLayoutX = 0
    private var m_nLayoutW = 0
    private var m_nLayoutH = 0
    private var m_nLayoutY = SEPARATE_HEIGHT
    
    // ------ data members ------
    private var m_editType: EditType = .EDIT_TYPE_NEW   // 编辑状态
    private var m_dicCategory: [Int:[Category]] = [:]   // key是Category Collection的ID, value是Category数组
    private var m_arrCC: [CategoryCollection] = []      // Category Collection
    private var m_dicPosition: [Int:[Position]] = [:]   // key是Area的ID, value是Position数组
    private var m_arrArea: [Area] = []                  // 所有Area
    private var m_arrOwner: [Owner] = []                // 所有Owner
    private var m_arrMarchant: [Marchant] = []          // 所有Marchant
    
    private var m_selectedCategory: Category!           // 用户通过pickerView选择的分类
    private var m_selectedPosition: Position!           // 用户通过pickerView选择的地点
    private var m_selectedOwner: Owner!                 // 用户通过pickerView选择的用户
    private var m_selectedMarchant: Marchant!           // 用户通过pickerView选择的商家
    
    private var m_inputThing: Thing!                    // 编辑状态传回的实例
    private var m_inputDefaultCategory: Category?       // 传回默认分类值
    
    private var m_arrCategoryDatasource: [Category]!    // pickerView使用的数据源
    private var m_arrPositionDatasource: [Position]!    // pickerView使用的数据源
    
    private var m_oldDate: Date!                        // 记录修改之前的日期
    private var m_oldExpeir: Date!                      // 记录修改之前的过期日期
    
    
    // ---------------------------------------------------------------------
    // MARK: Initial
    init(category: Category) {
        m_editType = .EDIT_TYPE_NEW
        m_inputDefaultCategory = category
        super.init(nibName: nil, bundle: nil)
    }
    
    init(position: Position) {
        m_editType = .EDIT_TYPE_NEW
        super.init(nibName: nil, bundle: nil)
    }
    
    init(thing: Thing, editType: EditType) {
        m_inputThing = thing
        m_editType = editType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // ------------------------------------------------------------------------
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ------ data members initial ------
        m_nLayoutX = SAFE_AREA_MARGIN
        m_nLayoutW = Int(UIScreen.main.bounds.size.width) - SAFE_AREA_MARGIN * 2
        m_nLayoutH = DEFAULT_HEIGHT
        
        // navigation controller
        switch m_editType {
        case .EDIT_TYPE_EDIT:
            self.navigationItem.title = "编辑 \(m_inputThing.name)"
        case .EDIT_TYPE_NEW:
            self.navigationItem.title = "添加物品"
        case .EDIT_TYPE_VIEW:
            self.navigationItem.title = m_inputThing.name
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop_menu"), style: .plain, target: self, action: #selector(self.showMenu))
        }
        
        // ------ layout and deal data ------
        layout()
        loadData()
        
        // ------ keyboard notification ------
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    
    // ---------------------------------------------------------------------------
    // MARK: Function Members
    
    // ------ layout ------
    func layout() {
        
        // ------ scrollView ------
        m_scrollView = UIScrollView(frame: self.view.bounds)
        if m_editType == .EDIT_TYPE_VIEW {
            m_scrollView.contentSize = CGSize(width: Int(self.view.bounds.size.width), height: (DEFAULT_HEIGHT * 32 + SEPARATE_HEIGHT * 18 + THING_IMG_SIZE))
        } else {
            m_scrollView.contentSize = CGSize(width: Int(self.view.bounds.size.width), height: (DEFAULT_HEIGHT * 25 + SEPARATE_HEIGHT * 18 + THING_IMG_SIZE))
        }
        m_scrollView.backgroundColor = UIColor.white
        self.view.addSubview(m_scrollView)
        
        
        // ------ pickerView ------
        let framePickerView = CGRect(x: 0, y: Int(self.view.bounds.size.height) - PVHEIGHT, width: Int(self.view.bounds.size.width), height: PVHEIGHT)
        
        m_pvCategory = UIPickerView(frame: framePickerView)
        m_pvCategory.backgroundColor = UIColor.white
        m_pvCategory.delegate = self
        m_pvCategory.dataSource = self
        
        m_pvPosition = UIPickerView(frame: framePickerView)
        m_pvPosition.backgroundColor = UIColor.white
        m_pvPosition.delegate = self
        m_pvPosition.dataSource = self
        
        m_pvOwner = UIPickerView(frame: framePickerView)
        m_pvOwner.backgroundColor = UIColor.white
        m_pvOwner.delegate = self
        m_pvOwner.dataSource = self
        
        m_pvMarchant = UIPickerView(frame: framePickerView)
        m_pvMarchant.backgroundColor = UIColor.white
        m_pvMarchant.delegate = self
        m_pvMarchant.dataSource = self
        
        
        // ------ date pickerView ------
        m_dpPurchaseDate = UIDatePicker(frame: framePickerView)
        m_dpPurchaseDate.locale = Locale(identifier: "zh")
        m_dpPurchaseDate.datePickerMode = .date
        
        m_dpExpeirDate = UIDatePicker(frame: framePickerView)
        m_dpExpeirDate.locale = Locale(identifier: "zh")
        m_dpExpeirDate.datePickerMode = .date
        
        
        // ------ toolbar ------
        m_toolBarPickerView = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let bbiPVDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pickerViewDone))
        let bbiFlexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        m_toolBarPickerView.items = [bbiFlexible, bbiPVDone]
        
        m_toolBarPurchaseDate = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let bbiDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dpDateDone))
        let bbiCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dpDateCancel))
        m_toolBarPurchaseDate.items = [bbiCancel, bbiFlexible, bbiDone]
        
        m_toolBarExpeirDate = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        let bbiExpeirDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dpExpeirDone))
        let bbiExpeirCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dpExpeirCancel))
        m_toolBarExpeirDate.items = [bbiExpeirCancel, bbiFlexible, bbiExpeirDone]
        
        
        // ------ gesture ------
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureSelectImageAction))
        let tapGestureCamera = UITapGestureRecognizer(target: self, action: #selector(tapGestureCameraAction(_:)))
        let tapGestureCloseImageView = UITapGestureRecognizer(target: self, action: #selector(tapGestureCloseImage(_:)))
        let tapGestureShowPositionThumb = UITapGestureRecognizer(target: self, action: #selector(tapGestureShowPositionThumbImage(_:)))
        let tapGestureShowOwnerThumb = UITapGestureRecognizer(target: self, action: #selector(tapGestureShowOwnerThumbImage(_:)))
        let tapGestureShowMarchantThumb = UITapGestureRecognizer(target: self, action: #selector(tapGestureShowMarchantThumbImage(_:)))
        
        
        // ---- Show Image View ----
        m_viewShowImage = UIView(frame: UIScreen.main.bounds)
        m_viewShowImage.backgroundColor = UIColor.black
        m_imgViewShowImg = UIImageView(frame: CGRect(x: 0, y: (m_viewShowImage.bounds.size.height - m_viewShowImage.bounds.size.width) / 2, width: m_viewShowImage.bounds.size.width, height: m_viewShowImage.bounds.size.width))
        m_imgViewShowImg.layer.cornerRadius = CORNER_RADIUS
        m_imgViewShowImg.layer.masksToBounds = true
        m_viewShowImage.addSubview(m_imgViewShowImg)
        m_viewShowImage.addGestureRecognizer(tapGestureCloseImageView)
        
        
        // ------ 物品图片 ------
        let frameImage = CGRect(x: m_nLayoutX + ((m_nLayoutW - THING_IMG_SIZE) / 2), y: m_nLayoutY, width: THING_IMG_SIZE, height: THING_IMG_SIZE)
        m_nLayoutY = m_nLayoutY + THING_IMG_SIZE + SEPARATE_HEIGHT
        let image = UIImage(named: "default_thing")
        m_imageView = UIImageView(frame: frameImage)
        m_imageView.image = image
        m_imageView.layer.cornerRadius = CORNER_RADIUS
        m_imageView.layer.masksToBounds = true
        m_imageView.isUserInteractionEnabled = true
        m_imageView.addGestureRecognizer(tapGesture)
        m_scrollView.addSubview(m_imageView)
        
        
        // ------ 启动摄像头 ------
        let frameCamera = CGRect(x: (Int(frameImage.origin.x + frameImage.size.width) + SEPARATE_HEIGHT),
                                 y: (Int(frameImage.origin.y + frameImage.size.height) - CAMERA_IMG_SIZE),
                                 width: CAMERA_IMG_SIZE,
                                 height: CAMERA_IMG_SIZE)
        let imgCamera = UIImage(named: "camera_button")
        let imgViewCamera = UIImageView(frame: frameCamera)
        imgViewCamera.image = imgCamera
        if m_editType == .EDIT_TYPE_NEW || m_editType == .EDIT_TYPE_EDIT {
            imgViewCamera.isUserInteractionEnabled = true
            imgViewCamera.addGestureRecognizer(tapGestureCamera)
            m_scrollView.addSubview(imgViewCamera)
        }
        
        
        // ------ 物品名称 ------
        let lblName = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblName.text = "物品名称："
        lblName.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblName)
        
        m_tfName = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfName.returnKeyType = .done
        m_tfName.delegate = self
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfName.isEnabled = false
            m_tfName.borderStyle = .none
        } else {
            m_tfName.borderStyle = .roundedRect
            m_tfName.clearButtonMode = .whileEditing
        }
        m_scrollView.addSubview(m_tfName)
        
        
        // ------ 物品分类 ------
        let lblCategory = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblCategory.text = "物品分类："
        lblCategory.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblCategory)
        
        m_tfCategory = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfCategory.inputView = m_pvCategory
        m_tfCategory.inputAccessoryView = m_toolBarPickerView
        m_tfCategory.delegate = self
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfCategory.isEnabled = false
            m_tfCategory.borderStyle = .none
        } else {
            m_tfCategory.borderStyle = .roundedRect
            m_tfCategory.returnKeyType = .done
            m_tfCategory.tintColor = UIColor.clear            // 隐藏光标
        }
        m_scrollView.addSubview(m_tfCategory)
        
        
        // ------ 存储位置 ------
        let imgViewPositionThumbY = m_nLayoutY
        let lblPosition = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblPosition.text = "存储位置："
        lblPosition.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblPosition)
        
        m_tfPosition = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfPosition.inputView = m_pvPosition
        m_tfPosition.inputAccessoryView = m_toolBarPickerView
        m_tfPosition.tintColor = UIColor.clear            // 隐藏光标
        m_tfPosition.delegate = self
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfPosition.isEnabled = false
            m_tfPosition.borderStyle = .none
        } else {
            m_tfPosition.borderStyle = .roundedRect
            m_tfPosition.returnKeyType = .done
            m_tfPosition.tintColor = UIColor.clear            // 隐藏光标
        }
        m_scrollView.addSubview(m_tfPosition)
        
        
        // ------ 存储位置图片 ------
        if m_editType == .EDIT_TYPE_VIEW {
            m_imgViewPositionThumb = UIImageView(frame: CGRect(x: Int(m_nLayoutX + m_nLayoutW - DEFAULT_HEIGHT * 2), y: imgViewPositionThumbY, width: DEFAULT_HEIGHT * 2, height: DEFAULT_HEIGHT * 2))
            m_imgViewPositionThumb.layer.cornerRadius = 8
            m_imgViewPositionThumb.layer.masksToBounds = true
            m_imgViewPositionThumb.isUserInteractionEnabled = true
            m_imgViewPositionThumb.addGestureRecognizer(tapGestureShowPositionThumb)
            m_scrollView.addSubview(m_imgViewPositionThumb)
        }
        
        
        // ------ 拥有者 ------
        let imgViewOwnerThumbY = m_nLayoutY
        let lblOwner = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblOwner.text = "拥有者："
        lblOwner.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblOwner)
        
        m_tfOwner = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfOwner.inputView = m_pvOwner
        m_tfOwner.inputAccessoryView = m_toolBarPickerView
        m_tfOwner.delegate = self
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfOwner.isEnabled = false
            m_tfOwner.borderStyle = .none
        } else {
            m_tfOwner.borderStyle = .roundedRect
            m_tfOwner.returnKeyType = .done
            m_tfOwner.tintColor = UIColor.clear            // 隐藏光标
        }
        m_scrollView.addSubview(m_tfOwner)
        
        
        // ------ 拥有者缩略图片 ------
        if m_editType == .EDIT_TYPE_VIEW {
            m_imgViewOwnerThumb = UIImageView(frame: CGRect(x: Int(m_nLayoutX + m_nLayoutW - DEFAULT_HEIGHT * 2), y: imgViewOwnerThumbY, width: DEFAULT_HEIGHT * 2, height: DEFAULT_HEIGHT * 2))
            m_imgViewOwnerThumb.layer.cornerRadius = 8
            m_imgViewOwnerThumb.layer.masksToBounds = true
            m_imgViewOwnerThumb.isUserInteractionEnabled = true
            m_imgViewOwnerThumb.addGestureRecognizer(tapGestureShowOwnerThumb)
            m_scrollView.addSubview(m_imgViewOwnerThumb)
        }
        
        
        // ------ 价格 ------
        let lblPrice = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblPrice.text = "价格："
        lblPrice.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblPrice)
        
        m_tfPrice = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfPrice.delegate = self
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfPrice.isEnabled = false
            m_tfPrice.borderStyle = .none
        } else {
            m_tfPrice.borderStyle = .roundedRect
            m_tfPrice.returnKeyType = .done
            m_tfPrice.keyboardType = .numberPad
            m_tfPrice.text = "0"
            m_tfPrice.clearsOnBeginEditing = true
            m_tfPrice.tintColor = UIColor.clear            // 隐藏光标
        }
        m_scrollView.addSubview(m_tfPrice)
        
        
        // ------ 商家 ------
        let imgViewMarchantThumbY = m_nLayoutY
        let lblMarchant = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblMarchant.text = "商家："
        lblMarchant.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblMarchant)
        
        m_tfMarchant = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        m_tfMarchant.inputView = m_pvMarchant
        m_tfMarchant.inputAccessoryView = m_toolBarPickerView
        m_tfMarchant.delegate = self
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfMarchant.isEnabled = false
            m_tfMarchant.borderStyle = .none
        } else {
            m_tfMarchant.borderStyle = .roundedRect
            m_tfMarchant.returnKeyType = .done
            m_tfMarchant.tintColor = UIColor.clear            // 隐藏光标
        }
        m_scrollView.addSubview(m_tfMarchant)
        
        
        // ------ 商家缩略图片 ------
        if m_editType == .EDIT_TYPE_VIEW {
            m_imgViewMarchantThumb = UIImageView(frame: CGRect(x: Int(m_nLayoutX + m_nLayoutW - DEFAULT_HEIGHT * 2), y: imgViewMarchantThumbY, width: DEFAULT_HEIGHT * 2, height: DEFAULT_HEIGHT * 2))
            m_imgViewMarchantThumb.layer.cornerRadius = 8
            m_imgViewMarchantThumb.layer.masksToBounds = true
            m_imgViewMarchantThumb.isUserInteractionEnabled = true
            m_imgViewMarchantThumb.addGestureRecognizer(tapGestureShowMarchantThumb)
            m_scrollView.addSubview(m_imgViewMarchantThumb)
        }
        
        
        // ------ 购买/获得日期 ------
        let lblPurchaseDate = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblPurchaseDate.text = "购买/获得日期："
        lblPurchaseDate.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblPurchaseDate)
        
        m_tfPurchaseDate = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfPurchaseDate.isEnabled = false
            m_tfPurchaseDate.borderStyle = .none
        } else {
            m_tfPurchaseDate.borderStyle = .roundedRect
            m_tfPurchaseDate.returnKeyType = .done
            m_tfPurchaseDate.tintColor = UIColor.clear            // 隐藏光标
            m_tfPurchaseDate.inputView = m_dpPurchaseDate
            m_tfPurchaseDate.inputAccessoryView = m_toolBarPurchaseDate
            m_tfPurchaseDate.delegate = self
        }
        m_scrollView.addSubview(m_tfPurchaseDate)
        
        
        // ------ 废弃/到期/过期日期 ------
        let lblExpeirDate = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblExpeirDate.text = "废弃/到期/过期日期："
        lblExpeirDate.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblExpeirDate)
        
        m_tfExpeirDate = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfExpeirDate.isEnabled = false
            m_tfExpeirDate.borderStyle = .none
        } else {
            m_tfExpeirDate.borderStyle = .roundedRect
            m_tfExpeirDate.returnKeyType = .done
            m_tfExpeirDate.tintColor = UIColor.clear            // 隐藏光标
            m_tfExpeirDate.inputView = m_dpExpeirDate
            m_tfExpeirDate.inputAccessoryView = m_toolBarExpeirDate
            m_tfExpeirDate.delegate = self
        }
        m_scrollView.addSubview(m_tfExpeirDate)
        
        
        // ------ 类型/规格/型号/品牌 ------
        let lblType = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblType.text = "类型/规格/型号/品牌："
        lblType.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblType)
        
        m_tfType = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfType.isEnabled = false
            m_tfType.borderStyle = .none
        } else {
            m_tfType.borderStyle = .roundedRect
            m_tfType.returnKeyType = .done
            m_tfType.clearButtonMode = .whileEditing
            m_tfType.delegate = self
        }
        m_scrollView.addSubview(m_tfType)
        
        
        // ------ 描述 ------
        let lblDetail = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblDetail.text = "描述："
        lblDetail.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblDetail)
        
        m_tfDetail = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfDetail.isEnabled = false
            m_tfDetail.borderStyle = .none
        } else {
            m_tfDetail.borderStyle = .roundedRect
            m_tfDetail.returnKeyType = .done
            m_tfDetail.clearButtonMode = .whileEditing
            m_tfDetail.delegate = self
        }
        m_scrollView.addSubview(m_tfDetail)
        
        
        // ------ 数量 ------
        let lblCount = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblCount.text = "数量："
        lblCount.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblCount)
        
        m_tfCount = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfCount.isEnabled = false
            m_tfCount.borderStyle = .none
        } else {
            m_tfCount.borderStyle = .roundedRect
            m_tfCount.returnKeyType = .done
            m_tfCount.clearButtonMode = .whileEditing
            m_tfCount.keyboardType = .numberPad
            m_tfCount.text = "1"
            m_tfCount.delegate = self
        }
        m_scrollView.addSubview(m_tfCount)
        
        
        // ------ 最大数量 ------
        let lblMaxCount = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY += m_nLayoutH
        lblMaxCount.text = "最大数量："
        lblMaxCount.textColor = UIColor.darkGray
        m_scrollView.addSubview(lblMaxCount)
        
        m_tfMaxCount = UITextField(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
        m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
        if m_editType == .EDIT_TYPE_VIEW {
            m_tfMaxCount.isEnabled = false
            m_tfMaxCount.borderStyle = .none
        } else {
            m_tfMaxCount.borderStyle = .roundedRect
            m_tfMaxCount.returnKeyType = .done
            m_tfMaxCount.clearButtonMode = .whileEditing
            m_tfMaxCount.keyboardType = .numberPad
            m_tfMaxCount.text = "1"
            m_tfMaxCount.delegate = self
        }
        m_scrollView.addSubview(m_tfMaxCount)
        
        
        if m_editType == .EDIT_TYPE_VIEW {
            // ---- ID ----
            let lblID = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            lblID.text = "ID："
            lblID.textColor = UIColor.darkGray
            m_scrollView.addSubview(lblID)
            
            m_lblID = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
            m_scrollView.addSubview(m_lblID)
            
            // ---- 状态 ----
            let lblState = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            lblState.text = "状态："
            lblState.textColor = UIColor.darkGray
            m_scrollView.addSubview(lblState)
            
            m_lblState = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
            m_scrollView.addSubview(m_lblState)
            
            // ---- 创建时间 ----
            let lblCT = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            lblCT.text = "创建时间："
            lblCT.textColor = UIColor.darkGray
            m_scrollView.addSubview(lblCT)
            
            m_lblCT = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY = m_nLayoutY + m_nLayoutH + SEPARATE_HEIGHT
            m_scrollView.addSubview(m_lblCT)
            
            // ---- 修改时间 ----
            let lblMT = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_nLayoutY += m_nLayoutH
            lblMT.text = "修改时间："
            lblMT.textColor = UIColor.darkGray
            m_scrollView.addSubview(lblMT)
            
            m_lblMT = UILabel(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutW, height: m_nLayoutH))
            m_scrollView.addSubview(m_lblMT)
        } else {
            // ------ 完成按钮 ------
            m_btnDone = UIButton(frame: CGRect(x: m_nLayoutX, y: m_nLayoutY + SEPARATE_HEIGHT * 2, width: m_nLayoutW, height: m_nLayoutH))
            m_btnDone.setTitle("完成", for: .normal)
            m_btnDone.setTitleColor(UIColor.darkGray, for: .normal)
            m_btnDone.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
            m_btnDone.addTarget(self, action: #selector(btnDoneAction(_:)), for: UIControlEvents.touchDown)
            m_scrollView.addSubview(m_btnDone)
        }
    }
    
    
    // ------ deal data ------
    func loadData() {
        
        if m_editType == .EDIT_TYPE_NEW || m_editType == .EDIT_TYPE_EDIT {  // 新建和编辑状态，初始化一些成员变量
            m_arrCC = DP.dp.getCCs(state: .STATE_NORMAL)
            m_arrArea = DP.dp.getAreas(state: .STATE_NORMAL)
            m_arrOwner = DP.dp.getOwners(state: .STATE_NORMAL)
            m_arrMarchant = DP.dp.getMarchants(state: .STATE_NORMAL)
            
            for item in m_arrCC {
                m_dicCategory[item.id] = DP.dp.getCategorys(inCC: item, state: .STATE_NORMAL)
            }
            for item in m_arrArea {
                m_dicPosition[item.id] = DP.dp.getPositions(inArea: item, state: .STATE_NORMAL)
            }
            
            m_arrCategoryDatasource = m_dicCategory[(m_arrCC.first?.id)!]
            m_arrPositionDatasource = m_dicPosition[(m_arrArea.first?.id)!]
            
            if m_inputDefaultCategory != nil {
                m_selectedCategory = m_inputDefaultCategory
            } else {
                m_selectedCategory = (m_dicCategory[(m_arrCC.first?.id)!])?.first
            }
            m_selectedPosition = (m_dicPosition[(m_arrArea.first?.id)!])?.first
            m_selectedOwner = m_arrOwner.first
            m_selectedMarchant = m_arrMarchant.first
        }
        
        
        if m_editType == .EDIT_TYPE_NEW {   // 新建状态，一些文本域默认值
            
            m_tfCategory.text = m_selectedCategory.name
            m_tfPosition.text = (m_dicPosition[m_arrArea[0].id])?[0].name
            m_tfOwner.text = m_arrOwner[0].name
            m_tfMarchant.text = m_arrMarchant[0].name
            
            let dateNow = Date()
            m_dpPurchaseDate.date = dateNow
            m_tfPurchaseDate.text = date2String(date: dateNow, dateFormat: "yyyy-MM-dd")
            m_oldDate = dateNow

            let dateExpeir = dateNow + 31536000
            m_dpExpeirDate.date = dateExpeir
            m_tfExpeirDate.text = date2String(date: dateExpeir, dateFormat: "yyyy-MM-dd")
            m_oldExpeir = dateExpeir
        }
        
        if m_editType == .EDIT_TYPE_EDIT || m_editType == .EDIT_TYPE_VIEW {     // 编辑状态下，一些控件的默认值
            
            m_tfName.text = m_inputThing.name
            m_tfCount.text = String(m_inputThing.count)
            m_tfMaxCount.text = String(m_inputThing.maxcount)
            m_tfPrice.text = String(m_inputThing.price)
            m_tfType.text = m_inputThing.type
            m_tfDetail.text = m_inputThing.detail
            m_selectedCategory = DP.dp.getCategory(id: m_inputThing.category)
            if m_selectedCategory != nil {
                m_tfCategory.text = m_selectedCategory.name
            }
            m_selectedPosition = DP.dp.getPosition(id: m_inputThing.position)
            if m_selectedPosition != nil {
                m_tfPosition.text = m_selectedPosition.name
            }
            m_selectedOwner = DP.dp.getOwner(id: m_inputThing.owner)!
            m_tfOwner.text = m_selectedOwner.name
            m_selectedMarchant = DP.dp.getMarchant(id: m_inputThing.marchant)!
            m_tfMarchant.text = m_selectedMarchant.name
            
            var imgThing = DP.dp.loadImage(img: m_inputThing.img)         // 处理图片
            if imgThing == nil { imgThing = UIImage(named: "default_thing") }
            m_imageView.image = imgThing
            
            if m_editType == .EDIT_TYPE_VIEW {
                let imgPosition = DP.dp.loadImage(img: (DP.dp.getPosition(id: m_inputThing.position)?.img)!)
                if imgPosition != nil {
                    m_imgViewPositionThumb.image = imgPosition
                } else {
                    m_imgViewPositionThumb.image = UIImage(named: "default_position")
                }
                
                let imgOwner = DP.dp.loadImage(img: (DP.dp.getOwner(id: m_inputThing.owner)?.img)!)
                if imgOwner != nil {
                    m_imgViewOwnerThumb.image = imgOwner
                } else {
                    m_imgViewOwnerThumb.image = UIImage(named: "all_owner")
                }
                
                let imgMarchant = DP.dp.loadImage(img: (DP.dp.getMarchant(id: m_inputThing.marchant)?.img)!)
                if imgMarchant != nil {
                    m_imgViewMarchantThumb.image = imgMarchant
                } else {
                    m_imgViewMarchantThumb.image = UIImage(named: "default_marchant")
                }
                
                m_lblID.text = "\(m_inputThing.id)"
                m_lblState.text = getStateName(state: m_inputThing.state)
                m_lblCT.text = date2String(date: m_inputThing.createtime, dateFormat: "yyyy-MM-dd HH:mm:ss")
                m_lblMT.text = date2String(date: m_inputThing.modifytime, dateFormat: "yyyy-MM-dd HH:mm:ss")
            }
            
            m_tfPurchaseDate.text = date2String(date: m_inputThing.date, dateFormat: "yyyy-MM-dd")
            m_oldDate = m_inputThing.date
            
            m_dpExpeirDate.date = m_inputThing.expeir
            m_tfExpeirDate.text = date2String(date: m_inputThing.expeir, dateFormat: "yyyy-MM-dd")
            m_oldExpeir = m_inputThing.expeir
        }
    }
    
    // ---------------------------------------------------------------
    // MARK: PickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {   // 列数量
        if pickerView == m_pvCategory || pickerView == m_pvPosition {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {    // 每列的行数
        if pickerView == m_pvCategory {
            if component == 0 {
                return m_arrCC.count
            } else {
                return m_arrCategoryDatasource.count
            }
        } else if pickerView == m_pvPosition {
            if component == 0 {
                return m_arrArea.count
            } else {
                return m_arrPositionDatasource.count
            }
        } else if pickerView == m_pvOwner {
            return m_arrOwner.count
        } else {
            return m_arrMarchant.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {     // 每行的内容
        if pickerView == m_pvCategory {
            if component == 0 {
                return m_arrCC[row].name
            } else {
                return m_arrCategoryDatasource[row].name
            }
        } else if pickerView == m_pvPosition {
            if component == 0 {
                return m_arrArea[row].name
            } else {
                return m_arrPositionDatasource[row].name
            }
        } else if pickerView == m_pvOwner {
            return m_arrOwner[row].name
        } else {
            return m_arrMarchant[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {        // 选择某行
        if pickerView == m_pvCategory {
            if component == 0 {
                m_arrCategoryDatasource = m_dicCategory[m_arrCC[row].id]
                m_pvCategory.selectRow(0, inComponent: 1, animated: true)
                m_pvCategory.reloadComponent(1)
                
                if m_arrCategoryDatasource.count > 0 {
                    m_selectedCategory = m_arrCategoryDatasource.first
                    m_tfCategory.text = m_selectedCategory.name
                }
            } else {
                if !m_arrCategoryDatasource.isEmpty {
                    m_selectedCategory = m_arrCategoryDatasource[row]
                    m_tfCategory.text = m_selectedCategory.name
                }
            }
        } else if pickerView == m_pvPosition {
            if component == 0 {
                m_arrPositionDatasource = m_dicPosition[m_arrArea[row].id]
                m_pvPosition.selectRow(0, inComponent: 1, animated: true)
                m_pvPosition.reloadComponent(1)
                
                if m_arrPositionDatasource.count > 0 {
                    m_selectedPosition = m_arrPositionDatasource.first
                    m_tfPosition.text = m_selectedPosition.name
                }
            } else {
                if !m_arrPositionDatasource.isEmpty {
                    m_selectedPosition = m_arrPositionDatasource[row]
                    m_tfPosition.text = m_selectedPosition.name
                }
            }
        } else if pickerView == m_pvOwner {
            m_selectedOwner = m_arrOwner[row]
            m_tfOwner.text = m_selectedOwner.name
        } else {
            m_selectedMarchant = m_arrMarchant[row]
            m_tfMarchant.text = m_selectedMarchant.name
        }
    }
    
    
    // ------------------------------------------------------------------------
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
        
        m_imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    
    // ----------------------------------------------------------------------
    // MARK: Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == m_tfType || textField == m_tfDetail || textField == m_tfCount || textField == m_tfMaxCount {
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = 0 - g_dKeyboardHeight
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == m_tfType || textField == m_tfDetail || textField == m_tfCount || textField == m_tfMaxCount {
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
    
    
    // ---------------------------------------------------------------------------
    // MARK: UI Actions
    
    // ------ Button Actions ------
    @objc private func btnDoneAction(_ sender: UIButton) {      // 点击完成按钮
        // 进行一些输入检测
        if (m_tfName.text == "") {
            alertTip(vc: self, message: "物品名称不能为空")
            return
        }
        
        var count: Int? = Int(m_tfCount.text!)
        if count == nil {
            count = 1
        }
        
        var maxCount: Int? = Int(m_tfMaxCount.text!)
        if maxCount == nil {
            maxCount = 1
        }
        
        var price: Double? = Double(m_tfPrice.text!)
        if price == nil {
            price = 0.0
        }
        
        // 保存图片
        let img = m_imageView.image
        var imgPath = ""
        if img != nil {
            imgPath = DP.dp.saveImage(img: img!)!
        }
        
        if m_editType == .EDIT_TYPE_NEW {   //添加状态
            let rst = DP.dp.addThing(name: m_tfName.text!, category: m_selectedCategory, position: m_selectedPosition, owner: m_selectedOwner, count: count!, maxcount: maxCount!, date: m_dpPurchaseDate.date, expeir: m_dpExpeirDate.date, price: price!, img: imgPath, marchant: m_selectedMarchant, type: m_tfType.text!, detail: m_tfDetail.text!, state: .STATE_NORMAL)
            if rst != 0 {
                tipLabel(view: self.view, strTip: "添加物品 \(m_tfName.text!) 成功")
            } else {
                tipLabel(view: self.view, strTip: "添加物品 \(m_tfName.text!) 失败，返回值 \(rst)")
            }
            
            if delegate != nil {delegate?.refresh(p: nil)}
        }
        
        if m_editType == .EDIT_TYPE_EDIT {     // 编辑状态
            // 删除以前的照片
            _ = DP.dp.deleteImage( img: m_inputThing.img )
            
            let now = Date()
            // 更新数据库
            let thing = Thing(id: m_inputThing.id, name: m_tfName.text!, category: m_selectedCategory.id, position: m_selectedPosition.id, owner: m_selectedOwner.id, count: count!, maxcount: maxCount!, date: m_dpPurchaseDate.date, expeir: m_dpExpeirDate.date, price: price!, img: imgPath, marchant: m_selectedMarchant.id, type: m_tfType.text!, detail: m_tfDetail.text!, state: m_inputThing.state, createtime: m_inputThing.createtime, modifytime: now)
            let rst = DP.dp.updateThing(thing: thing)
            if rst != 0 {
                tipLabel(view: self.view, strTip: "更新物品 \(m_tfName.text!) 成功")
                if delegate != nil { delegate?.refresh(p: thing) }
            } else {
                tipLabel(view: self.view, strTip: "更新物品 \(m_tfName.text!) 失败，返回值 \(rst)")
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func pickerViewDone() {
        m_tfCategory.resignFirstResponder()
        m_tfPosition.resignFirstResponder()
        m_tfOwner.resignFirstResponder()
        m_tfMarchant.resignFirstResponder()
    }
    
    @objc func dpDateDone() {
        m_tfPurchaseDate.text = date2String(date: m_dpPurchaseDate.date, dateFormat: "yyyy-MM-dd")
        m_oldDate = m_dpPurchaseDate.date
        m_tfPurchaseDate.resignFirstResponder()
    }
    
    @objc func dpDateCancel() {
        m_dpPurchaseDate.date = m_oldDate
        m_tfPurchaseDate.resignFirstResponder()
    }
    
    @objc func dpExpeirDone() {
        m_tfExpeirDate.text = date2String(date: m_dpExpeirDate.date, dateFormat: "yyyy-MM-dd")
        m_oldExpeir = m_dpExpeirDate.date
        m_tfExpeirDate.resignFirstResponder()
    }
    
    @objc func dpExpeirCancel() {
        m_dpExpeirDate.date = m_oldExpeir
        m_tfExpeirDate.resignFirstResponder()
    }
    
    
    // ------ Gesture Action ------
    @objc func tapGestureSelectImageAction(_ sender: UITapGestureRecognizer) {  // 选择图片的手势识别动作函数
        
        if m_editType == .EDIT_TYPE_NEW || m_editType == .EDIT_TYPE_EDIT {
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        } else if m_editType == .EDIT_TYPE_VIEW {
            var image = DP.dp.loadImage(img: m_inputThing.img)
            if image == nil {
                image = UIImage(named: "default_thing")
            }
            m_imgViewShowImg.image = image
            self.navigationController?.isNavigationBarHidden = true
            self.view.addSubview(m_viewShowImage)
        }
    }
    
    @objc func tapGestureCloseImage(_ sender: UITapGestureRecognizer) {     // 查看图片完成的手势识别事件动作
        self.navigationController?.isNavigationBarHidden = false
        if m_viewShowImage != nil {
            m_viewShowImage.removeFromSuperview()
        }
    }
    
    @objc func tapGestureCameraAction(_ sender: UIButton) {
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
    
    @objc func tapGestureShowPositionThumbImage(_ sender: UITapGestureRecognizer) {  // 选择图片的手势识别动作函数
        if m_editType == .EDIT_TYPE_VIEW {
            var image = DP.dp.loadImage(img: (DP.dp.getPosition(id: m_inputThing.position)?.img)!)
            if image == nil {
                image = UIImage(named: "default_position")
            }
            m_imgViewShowImg.image = image
            self.navigationController?.isNavigationBarHidden = true
            self.view.addSubview(m_viewShowImage)
        }
    }
    
    @objc func tapGestureShowOwnerThumbImage(_ sender: UITapGestureRecognizer) {  // 选择图片的手势识别动作函数
        if m_editType == .EDIT_TYPE_VIEW {
            var image = DP.dp.loadImage(img: (DP.dp.getOwner(id: m_inputThing.owner)?.img)!)
            if image == nil {
                image = UIImage(named: "all_owner")
            }
            m_imgViewShowImg.image = image
            self.navigationController?.isNavigationBarHidden = true
            self.view.addSubview(m_viewShowImage)
        }
    }
    @objc func tapGestureShowMarchantThumbImage(_ sender: UITapGestureRecognizer) {  // 选择图片的手势识别动作函数
        if m_editType == .EDIT_TYPE_VIEW {
            var image = DP.dp.loadImage(img: (DP.dp.getMarchant(id: m_inputThing.marchant)?.img)!)
            if image == nil {
                image = UIImage(named: "default_marchant")
            }
            m_imgViewShowImg.image = image
            self.navigationController?.isNavigationBarHidden = true
            self.view.addSubview(m_viewShowImage)
        }
    }
    
    
    // ------ Pop Menu Actions ------
    @objc func showMenu() {
        m_popMenu = SwiftPopMenu(frame:  CGRect(x: self.view.bounds.size.width - 120, y: 51, width: 115, height: 412), arrowMargin: 12)
        
        m_popMenu.popData = [(icon:"thing_edit",title:"编辑物品"),
                             (icon:"thing_increase",title:"数量增加"),
                             (icon:"thing_decrease",title:"数量减少"),
                             (icon:"thing_category",title:"设为正常"),
                             (icon:"thing_category",title:"旧物保留"),
                             (icon:"thing_category",title:"全新备用"),
                             (icon:"thing_lost",title:"设为丢失"),
                             (icon:"thing_delete",title:"删除物品")]
        //点击菜单
        m_popMenu.didSelectMenuBlock = { [weak self](index:Int)->Void in
            self?.m_popMenu.dismiss()
            
            if index == 0 { // 编辑物品
                let vc = VCEditThing(thing: (self?.m_inputThing)!, editType: .EDIT_TYPE_EDIT)
                vc.delegate = self
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if index == 1 { // 数量增加
                if DP.dp.increaseThings(things: (self?.m_inputThing)!) != 0 {
                    tipLabel(view: self!.view, strTip: "增加物品数量 \(String(describing: self?.m_inputThing.name)) 成功")
                    self?.m_inputThing.count += 1
                    self?.m_tfCount.text = String(describing: self!.m_inputThing.count)
                    if self?.delegate != nil { self?.delegate!.refresh(p: nil)}
                } else {
                    tipLabel(view: self!.view, strTip: "增加物品数量 \(String(describing: self?.m_inputThing.name)) 失败")
                }
            } else if index == 2 { // 数量减少
                if (self?.m_inputThing.count)! < 1 {
                    return
                } else {
                    if DP.dp.decreaseThings(things: (self?.m_inputThing)!) != 0 {
                        tipLabel(view: self!.view, strTip: "减少物品数量 \(String(describing: self?.m_inputThing.name)) 成功")
                        self?.m_inputThing.count -= 1
                        self?.m_tfCount.text = String(describing: self!.m_inputThing.count)
                        if self?.delegate != nil { self?.delegate!.refresh(p: nil)}
                    } else {
                        tipLabel(view: self!.view, strTip: "减少物品数量 \(String(describing: self?.m_inputThing.name)) 失败")
                    }
                }
            } else if index == 3 { // 设为正常
                if DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_NORMAL) != 0 {
                    tipLabel(view: self!.view, strTip: "设置正常状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    if self?.delegate != nil { self?.delegate!.refresh(p: nil) }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置正常状态 \(String(describing: self?.m_inputThing.name)) 失败")
                }
            } else if index == 4 { // 设为保留
                if DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_STORAGE) != 0 {
                    tipLabel(view: self!.view, strTip: "设置旧物保留状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    if self?.delegate != nil { self?.delegate!.refresh(p: nil) }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置旧物保留状态 \(String(describing: self?.m_inputThing.name)) 失败")
                }
            } else if index == 5 { // 设为备用
                if DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_RESERVE) != 0 {
                    tipLabel(view: self!.view, strTip: "设置全新备用状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    if self?.delegate != nil { self?.delegate!.refresh(p: nil) }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置全新备用状态 \(String(describing: self?.m_inputThing.name)) 失败")
                }
            } else if index == 6 { // 设为丢失
                if DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_LOST) != 0 {
                    tipLabel(view: self!.view, strTip: "设置丢失状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    if self?.delegate != nil { self?.delegate!.refresh(p: nil) }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置丢失状态 \(String(describing: self?.m_inputThing.name)) 失败")
                }
            } else if index == 7 { // 删除物品
                if DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_DELETE) != 0 {
                    tipLabel(view: self!.view, strTip: "设置删除状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    if self?.delegate != nil { self?.delegate!.refresh(p: nil) }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置删除状态 \(String(describing: self?.m_inputThing.name)) 失败")
                }
            }
        }
        m_popMenu.show()
    }
    
    
    // -------------------------------------------------------------------
    // MARK: keyboard notification
    @objc func keyboardWillShow(aNotification: NSNotification) {
        let userinfo = aNotification.userInfo
        let nsValue = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRec = nsValue.cgRectValue
        g_dKeyboardHeight = keyboardRec.size.height
    }
    
    
    // ------ RefreshViewDelegate ------
    func refresh(p: Any?) {
        if delegate != nil {delegate?.refresh(p: p)}
        if p != nil {
            m_inputThing = p as! Thing
            self.navigationItem.title = m_inputThing.name
            loadData()
        }
    }
}
