//
//  VCViewCC.swift
//  MyThings
//
//  Created by LiWei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewCC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data member
    public var m_CC: CategoryCollection!                // 需要显示的分类组
    var m_arrData: [Category]!                          // tableview显示的分类

    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // 获取所属的所有分类
        m_arrData = DataProcess.dp.getCategoryByCC(id: m_CC.id)
        
        // navigation controller
        if m_CC == nil {
            self.navigationItem.title = "分类组详情"
        } else {
            self.navigationItem.title = "\(m_CC.name)（\(m_arrData.count)）"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // 设置视图控件默认值
        var img = DataProcess.dp.loadImage(img: m_CC.img)         // 处理图片
        if img == nil {
            img = UIImage(named: "default_cc")
        }
        imageView.image = img
        
        lblName.text = m_CC.name
        lblDetail.text = m_CC.detail
        
        // TableView代理
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        cell?.textLabel?.text = m_arrData[indexPath.row].name
        
        var img = DataProcess.dp.loadImage(img: m_arrData[indexPath.row].img)
        if img == nil {
            img = UIImage(named: "default_category")
        }
        cell?.imageView?.image = img
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: UI Actions
    func edit() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditCC") as! VCEditCC
        vc.isEdit = true
        vc.m_CC = m_CC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        if m_CC != nil {
            m_arrData = DataProcess.dp.getCategoryByCC(id: m_CC.id)
            tableView.reloadData()
            
            // 更新视图控件值
            m_CC = DataProcess.dp.getCC(id: m_CC.id)
            if m_CC == nil {
                return
            }
            var img = DataProcess.dp.loadImage(img: m_CC.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_cc")
            }
            imageView.image = img
            
            lblName.text = m_CC.name
            lblDetail.text = m_CC.detail
        }
    }
}
