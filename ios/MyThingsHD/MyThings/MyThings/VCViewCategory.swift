//
//  VCViewCategory.swift
//  MyThings
//
//  Created by LiWei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewCategory: UIViewController, UITableViewDelegate, UITableViewDataSource {            // 查看分类详情
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCC: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data members
    public var m_category: Category!                // 需要显示的分类
    var m_arrThings: [Thing]!
    
    // MARK: app delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        // 获取所属的所有物品
        m_arrThings = DataProcess.dp.getThingsByCategory(id: m_category.id)
        
        // navigation controller
        if m_category == nil {
            self.navigationItem.title = "分类详情"
        } else {
            self.navigationItem.title = "\(m_category.name)（\(m_arrThings.count)）"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // 现实分类详情数据
        var img = DataProcess.dp.loadImage(img: m_category.img)         // 处理图片
        if img == nil {
            img = UIImage(named: "default_category")
        }
        imageView.image = img
        
        lblName.text = m_category.name
        lblCC.text = DataProcess.dp.getCC(id: m_category.cc)?.name
        lblDetail.text = m_category.detail
        
        // TableView代理
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrThings.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
        }
        cell?.accessoryType = .disclosureIndicator
//        cell?.textLabel?.text = m_arrThings[indexPath.row].name
//        
//        let strCategoryName = DataProcess.dp.getCategory(id: m_arrThings[indexPath.row].category)!.name
//        let strPositionName = DataProcess.dp.getPosition(id: m_arrThings[indexPath.row].position)!.name
//        let strOwnerName = DataProcess.dp.getOwner(id: m_arrThings[indexPath.row].owner)!.name
//        cell?.detailTextLabel?.text = "\(strPositionName) | \(strCategoryName) | \(strOwnerName)"
//        
//        var img = UIImage(contentsOfFile: m_arrThings[indexPath.row].img)
//        if img == nil {
//            img = UIImage(named: "default_thing")
//        }
//        cell?.imageView?.image = img
//        
//        return cell!
        
        return formatCell(cell: cell!, thing: m_arrThings[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewThing") as! VCViewThings
        vc.m_thing = m_arrThings[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: UI Actions
    func edit() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditCategory") as! VCEditCategory
        vc.m_category = m_category
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        if m_category != nil {
            m_arrThings = DataProcess.dp.getThingsByCategory(id: m_category.id)
            tableView.reloadData()
            
            // 更新视图控件值
            m_category = DataProcess.dp.getCategory(id: m_category.id)
            if m_category == nil {
                return
            }
            var img = DataProcess.dp.loadImage(img: m_category.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_category")
            }
            imageView.image = img
            
            lblName.text = m_category.name
            lblCC.text = DataProcess.dp.getCC(id: m_category.cc)?.name
            lblDetail.text = m_category.detail
        }
    }
}
