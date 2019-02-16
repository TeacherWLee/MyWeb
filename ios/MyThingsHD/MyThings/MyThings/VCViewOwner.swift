//
//  VCViewOwner.swift
//  MyThings
//
//  Created by LiWei on 2017/1/12.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewOwner: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data member
    public var m_owner: Owner!
    var m_arrData: [Thing]!                          // tableview显示的分类
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取所属的所有物品
        m_arrData = DataProcess.dp.getThingsByOwner(id: m_owner.id)
        
        // navigation controller
        if m_owner == nil {
            self.navigationItem.title = "用户详情"
        } else {
            self.navigationItem.title = "\(m_owner.name)（\(m_arrData.count)）"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // 设置视图控件默认值
        var img = DataProcess.dp.loadImage(img: m_owner.img)         // 处理图片
        if img == nil {
            if m_owner.name == "全体成员" {
                img = UIImage(named: "all_owner")
            } else if m_owner.name == "李巍" {
                img = UIImage(named: "liwei")
            } else if m_owner.name == "于砚卓" {
                img = UIImage(named: "yuyanzhuo")
            } else if m_owner.name == "李季耳" {
                img = UIImage(named: "lijier")
            }
        }
        imageView.image = img
        
        lblName.text = m_owner.name
        lblDetail.text = m_owner.detail
        
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
        cell?.accessoryType = .disclosureIndicator
        
        return formatCell(cell: cell!, thing: m_arrData[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewThing") as! VCViewThings
        vc.m_thing = m_arrData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UI Actions
    func edit() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditOwner") as! VCEditOwner
        vc.isEdit = true
        vc.m_owner = m_owner
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        if m_owner != nil {
            m_arrData = DataProcess.dp.getThingsByOwner(id: m_owner.id)
            tableView.reloadData()
            
            // 设置视图控件默认值
            m_owner = DataProcess.dp.getOwner(id: m_owner.id)
            if m_owner == nil {
                return
            }
            
            var img = DataProcess.dp.loadImage(img: m_owner.img)         // 处理图片
            if img == nil {
                if m_owner.name == "全体成员" {
                    img = UIImage(named: "all_owner")
                } else if m_owner.name == "李巍" {
                    img = UIImage(named: "liwei")
                } else if m_owner.name == "于砚卓" {
                    img = UIImage(named: "yuyanzhuo")
                } else if m_owner.name == "李季耳" {
                    img = UIImage(named: "lijier")
                }
            }
            imageView.image = img
            
            lblName.text = m_owner.name
            lblDetail.text = m_owner.detail
        }
    }
}
