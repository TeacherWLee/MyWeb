//
//  VCViewArea.swift
//  MyThings
//
//  Created by LiWei on 2017/1/12.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewArea: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UILabel!
    @IBOutlet weak var tfDetail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data member
    public var m_area: Area!
    var m_arrData: [Position]!                          // tableview显示的分类
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取所属的所有分类
        m_arrData = DataProcess.dp.getPositionByArea(id: m_area.id)
        
        // navigation controller
        if m_area == nil {
            self.navigationItem.title = "区域详情"
        } else {
            self.navigationItem.title = "\(m_area.name)（\(m_arrData.count)）"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // 设置视图控件默认值
        var img = DataProcess.dp.loadImage(img: m_area.img)         // 处理图片
        if img == nil {
            img = UIImage(named: "default_area")
        }
        imageView.image = img
        
        tfName.text = m_area.name
        tfDetail.text = m_area.detail
        
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
            img = UIImage(named: "default_position")
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
        let vc = sb.instantiateViewController(withIdentifier: "VCEditArea") as! VCEditArea
        vc.isEdit = true
        vc.m_area = m_area
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        if m_area != nil {
            m_arrData = DataProcess.dp.getPositionByArea(id: m_area.id)
            tableView.reloadData()
            
            // 更新视图控件值
            m_area = DataProcess.dp.getArea(id: m_area.id)
            if m_area == nil {
                return
            }
            var img = DataProcess.dp.loadImage(img: m_area.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_area")
            }
            imageView.image = img
            
            tfName.text = m_area.name
            tfDetail.text = m_area.detail
        }
    }
}
