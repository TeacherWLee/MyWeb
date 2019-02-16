//
//  VCViewThings.swift
//  MyThings
//
//  Created by Li Wei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewThings: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblMaxCount: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var lblOwner: UILabel!
    @IBOutlet weak var lblMarchant: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblExpeir: UILabel!
    @IBOutlet weak var lblTimestamp: UILabel!
    @IBOutlet weak var lblImg: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblID: UILabel!
    
    // data members
    public var m_thing:Thing!                           // 需要显示详情的事物
    private var m_imgViewShowImage: UIImageView!        // 显示图片的ImageView

    // MARK: app delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Controller
        if m_thing != nil {
            self.navigationItem.title = m_thing.name
        } else {
            self.navigationItem.title = "物品详情"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // deal data
        dealData()
    }
    
    // MARK: functions member
    func dealData() {       // 处理数据
        if m_thing != nil {
            // outlet赋值
            var imgThing = DataProcess.dp.loadImage(img: m_thing.img)         // 处理图片
            if imgThing == nil {
                imgThing = UIImage(named: "default_thing")
            }
            imageView.image = imgThing
            
            lblName.text = m_thing.name
            lblCount.text = String(m_thing.count)
            lblMaxCount.text = String(m_thing.maxcount)
            lblPrice.text = String(m_thing.price)
            lblType.text = m_thing.type
            lblDetail.text = m_thing.detail
            lblCategory.text = DataProcess.dp.getCategory(id: m_thing.category)?.name
            lblPosition.text = DataProcess.dp.getPosition(id: m_thing.position)?.name
            lblOwner.text = DataProcess.dp.getOwner(id: m_thing.owner)?.name
            lblMarchant.text = DataProcess.dp.getMarchant(id: m_thing.marchant)?.name
            
            let df = DateFormatter()
            df.locale = Locale.current
            df.dateFormat = "yyyy-MM-dd"
            lblDate.text = df.string(from: m_thing.date)
            lblExpeir.text = df.string(from: m_thing.expeir)
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            lblTimestamp.text = df.string(from: m_thing.timestamp)
            
            let arrImgPathSplit = m_thing.img.characters.split(separator: "/")      // 处理图片名称
            if arrImgPathSplit.count > 0 {
                lblImg.text = String(arrImgPathSplit[arrImgPathSplit.count-1])
            }
            lblState.text = String(m_thing.state)
            lblID.text = String(m_thing.id)
        } else {
            let alertCtrl = UIAlertController(title: "错误", message: "物品信息出错", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alertCtrl.addAction(alertAction)
            present(alertCtrl, animated: true, completion: nil)
        }
    }
    
    func refresh() {
        m_thing = DataProcess.dp.getThingsByID(id: m_thing.id)  // 获取数据库最新数据
        dealData()
    }
    
    // MARK: UI Actions
    func edit() {       // 导航控制器编辑按钮动作
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditThing") as! VCEditThings
        vc.isEdit = true
        vc.m_thing = m_thing
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnReturn(_ sender: UIButton) {  // 返回按钮事件动作
        //let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as! VCAllThings
        //vc.refresh()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnIncrease(_ sender: UIButton) {    // 增加数量按钮事件动作
        DataProcess.dp.increaseThings(things: m_thing)
        m_thing.count += 1
        lblCount.text = String(m_thing.count)
    
        self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].viewDidLoad()
    }
    
    @IBAction func btnDecrease(_ sender: UIButton) {    // 减少数量按钮事件动作
        if m_thing.count < 1 {
            return
        } else {
            DataProcess.dp.decreaseThings(things: m_thing)
            m_thing.count -= 1
            lblCount.text = String(m_thing.count)
            
            self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-2].viewDidLoad()
        }
    }
    
    @IBAction func btnDelete(_ sender: UIButton) {  // 删除按钮事件动作
        DataProcess.dp.deleteThings(things: m_thing)
        self.navigationController?.popViewController(animated: true)
        
        self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)!-1].viewDidLoad()
    }
    
    @IBAction func tapGestureSelectImage(_ sender: UITapGestureRecognizer) {    // 查看图片手势识别事件动作
        m_imgViewShowImage = UIImageView(frame: CGRect(x: 0, y: 128, width: 768, height: 768))
        m_imgViewShowImage.image = DataProcess.dp.loadImage(img: m_thing.img)
        if m_imgViewShowImage == nil {
            m_imgViewShowImage.image = UIImage(named: "default_thing")
        }
        self.view.addSubview(m_imgViewShowImage)
    }
    
    @IBAction func tapGestureCloseImage(_ sender: UITapGestureRecognizer) {     // 查看图片完成的手势识别事件动作
        if m_imgViewShowImage != nil {
            m_imgViewShowImage.removeFromSuperview()
        }
    }
}
