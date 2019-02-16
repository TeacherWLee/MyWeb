//
//  VCViewPosition.swift
//  MyThings
//
//  Created by LiWei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCViewPosition: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tfName: UILabel!
    @IBOutlet weak var tfArea: UILabel!
    @IBOutlet weak var tfDetail: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data members
    public var m_position: Position!                // 需要显示的位置
    var m_arrThings: [Thing]!                       // 属于该地点的物品

    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取所属的所有物品
        m_arrThings = DataProcess.dp.getThingsByPosition(id: m_position.id)
        
        // navigation controller
        if m_position == nil {
            self.navigationItem.title = "位置详情"
        } else {
            self.navigationItem.title = "\(m_position.name)（\(m_arrThings.count)）"
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        
        // 现实分类详情数据
        var img = DataProcess.dp.loadImage(img: m_position.img)         // 处理图片
        if img == nil {
            img = UIImage(named: "default_position")
        }
        imageView.image = img
        
        tfName.text = m_position.name
        tfArea.text = DataProcess.dp.getArea(id: m_position.area)?.name
        tfDetail.text = m_position.detail
        
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
        let vc = sb.instantiateViewController(withIdentifier: "VCEditPosition") as! VCEditPosition
        vc.m_position = m_position
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        if m_position != nil {
            m_arrThings = DataProcess.dp.getThingsByPosition(id: m_position.id)
            tableView.reloadData()
            
            // 更新视图控件值
            m_position = DataProcess.dp.getPosition(id: m_position.id)
            if m_position == nil {
                return
            }
            var img = DataProcess.dp.loadImage(img: m_position.img)         // 处理图片
            if img == nil {
                img = UIImage(named: "default_position")
            }
            imageView.image = img
            
            tfName.text = m_position.name
            tfArea.text = DataProcess.dp.getArea(id: m_position.area)?.name
            tfDetail.text = m_position.detail
        }
    }
}
