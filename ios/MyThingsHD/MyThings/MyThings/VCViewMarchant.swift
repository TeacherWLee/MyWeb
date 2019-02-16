//
//  VCViewMarchant.swift
//  MyThings
//
//  Created by LiWei on 2017/1/12.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewMarchant: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UILabel!
    @IBOutlet weak var tfDetail: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: data members
    public var m_marchant: Marchant!
    var m_arrData: [Thing]!                          // tableview显示的分类
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取所属的所有物品
        m_arrData = DataProcess.dp.getThingsByMarchant(id: m_marchant.id)
        
        // navigation controller
        if m_marchant == nil {
            self.navigationItem.title = "商家详情"
        } else {
            self.navigationItem.title = "\(m_marchant.name)（\(m_arrData.count)）"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // 设置视图控件默认值
        var img = DataProcess.dp.loadImage(img: m_marchant.img)         // 处理图片
        if img == nil {
            if m_marchant.name == "无" {
                img = UIImage(named: "none")
            } else {
                img = UIImage(named: "default_marchant")
            }
        }
        imageView.image = img
        
        tfName.text = m_marchant.name
        tfDetail.text = m_marchant.detail
        
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
//        cell?.textLabel?.text = m_arrData[indexPath.row].name
//        
//        var img = UIImage(contentsOfFile: m_arrData[indexPath.row].img)
//        if img == nil {
//            img = UIImage(named: "default_thing")
//        }
//        cell?.imageView?.image = img
//        
//        return cell!
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
        let vc = sb.instantiateViewController(withIdentifier: "VCEditMarchant") as! VCEditMarchant
        vc.isEdit = true
        vc.m_marchant = m_marchant
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        if m_marchant != nil {
            m_arrData = DataProcess.dp.getThingsByMarchant(id: m_marchant.id)
            tableView.reloadData()
            
            // 设置视图控件默认值
            m_marchant = DataProcess.dp.getMarchant(id: m_marchant.id)
            if m_marchant == nil {
                return
            }
            
            var img = DataProcess.dp.loadImage(img: m_marchant.img)         // 处理图片
            if img == nil {
                if m_marchant.name == "无" {
                    img = UIImage(named: "none")
                } else {
                    img = UIImage(named: "default_marchant")
                }
            }
            imageView.image = img
            
            tfName.text = m_marchant.name
            tfDetail.text = m_marchant.detail
        }
    }
}
