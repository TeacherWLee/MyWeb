//
//  VCThingDetail.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/20.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

// 指定一件物品的详细信息
class VCDetailThing: UIViewController {

    // --------------------------------------------------------------
    // MARK: Constant Value
    enum LabelType {                                    // 标签的类型
        case LABEL_TAG
        case LABEL_INFORMATION
    }
    
    
    // --------------------------------------------------------------
    // MARK: data members
    public var m_thing:Thing!                           // 需要显示详情的事物
    private var m_imgViewShowImage: UIImageView!        // 显示图片的ImageView
    private var m_scrollView: UIScrollView!             // 滚动视图
    private var m_nLayoutX = 0                          // 布局时，子视图X坐标
    private var m_nLayoutY = 0                          // 布局时，子视图Y坐标
    private var m_nLayoutWidth = 0                      // 布局时，子视图宽度
    
    
    // --------------------------------------------------------------
    // MARK: app delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // data members initial
        m_nLayoutX = SAFE_AREA_MARGIN
        m_nLayoutWidth = Int(self.view.bounds.size.width)
        m_nLayoutY = SEPARATE_HEIGHT
        
        // Navigation Controller
        if m_thing != nil {
            self.navigationItem.title = m_thing.name
        } else {
            self.navigationItem.title = "物品详情"
        }
        
        
        // 滚动视图
        m_scrollView = UIScrollView(frame: (self.view.bounds))
        m_scrollView.contentSize = CGSize(width: m_nLayoutWidth, height: 1370)
        m_scrollView.backgroundColor = UIColor.white
        self.view.addSubview(m_scrollView)
        m_nLayoutWidth -= SAFE_AREA_MARGIN * 2

        LayoutAndData()
    }
    
    
    // --------------------------------------------------------------
    // MARK: functions member
    // UI布局与数据绑定
    func LayoutAndData() {

        // 物品图片区域
        var frameImage = getNextFrame(height: DEFAULT_IMG_SIZE, isSeparate: true)
        var imgThing = DP.dp.loadImage(img: m_thing.img)         // 处理图片
        if imgThing == nil {
            imgThing = UIImage(named: "default_thing")
        }
        frameImage.origin.x = (m_scrollView.frame.size.width - CGFloat(DEFAULT_IMG_SIZE)) / 2
        frameImage.size.width = CGFloat(DEFAULT_IMG_SIZE)
        let imageView = UIImageView(frame: frameImage)
        imageView.image = imgThing
        m_scrollView.addSubview(imageView)
      
        // 物品名称
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "物品名称", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: m_thing.name, type: .LABEL_INFORMATION)
        
        // 物品分类
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "物品分类", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: (DP.dp.getCategory(id: m_thing.category)?.name)!, type: .LABEL_INFORMATION)
        
        // 物品地点
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "存储位置", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: (DP.dp.getPosition(id: m_thing.position)?.name)!, type: .LABEL_INFORMATION)
        
        // 拥有者
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "拥有者", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: (DP.dp.getOwner(id: m_thing.owner)?.name)!, type: .LABEL_INFORMATION)
        
        // 价格
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "价格", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: String(m_thing.price), type: .LABEL_INFORMATION)
        
        // 商家
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "商家", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: (DP.dp.getMarchant(id: m_thing.marchant)?.name)!, type: .LABEL_INFORMATION)
        
        // 获得/购买日期
        let df = DateFormatter()                // 日期格式化
        df.locale = Locale.current
        df.dateFormat = "yyyy-MM-dd"
        
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "获得/购买日期", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: df.string(from: m_thing.date), type: .LABEL_INFORMATION)
        
        // 废弃/到期/过期日期
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "废弃/到期/过期日期", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: df.string(from: m_thing.expeir), type: .LABEL_INFORMATION)
        
        // 类型规格型号品牌
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "类型/规格/型号/品牌", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: m_thing.type, type: .LABEL_INFORMATION)
        
        // 状态
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "状态", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: "正常", type: .LABEL_INFORMATION)
        
        // 描述
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "描述", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: m_thing.detail, type: .LABEL_INFORMATION)
        
        // 数量
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "数量", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: String(m_thing.count), type: .LABEL_INFORMATION)
        
        // 最大可拥有数量
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "最大可拥有数量", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: String(m_thing.maxcount), type: .LABEL_INFORMATION)
        
        // 最后编辑/录入时间
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "最后编辑/录入时间", type: .LABEL_TAG)
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: df.string(from: m_thing.modifytime), type: .LABEL_INFORMATION)
        
        // 图片名称
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "图片名称", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: String(m_thing.img), type: .LABEL_INFORMATION)
        
        // 物品ID
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "物品ID", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: String(m_thing.id), type: .LABEL_INFORMATION)
        
        // 状态值
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: false), strLabelText: "状态值", type: .LABEL_TAG)
        addLabelInScrollView(frame: getNextFrame(height: DEFAULT_HEIGHT, isSeparate: true), strLabelText: String(m_thing.state), type: .LABEL_INFORMATION)
    }
    
    func getNextFrame(height: Int, isSeparate: Bool) -> CGRect {
        let frame = CGRect(x: m_nLayoutX, y: m_nLayoutY, width: m_nLayoutWidth, height: height)
        
        m_nLayoutY += height
        
        if isSeparate {
            m_nLayoutY += SEPARATE_HEIGHT
        }
        
        return frame
    }
    
    func addLabelInScrollView(frame: CGRect, strLabelText: String, type: LabelType) {
        let label = UILabel(frame: frame)
        label.text = strLabelText
        label.font = UIFont.systemFont(ofSize: 18)
        if type == .LABEL_TAG {
            label.textColor = UIColor.darkGray
            label.font = UIFont.systemFont(ofSize: 16)
        }
        
        m_scrollView.addSubview(label)
    }
}
