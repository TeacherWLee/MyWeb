//
//  VCSetArea.swift
//  MyThings
//
//  Created by LiWei on 2017/1/9.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCSetArea: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: data members
    var m_arrArea: [Area]!       // 分类组数据源
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航控制器
        self.navigationItem.title = "区域"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // tableview delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        m_arrArea = DataProcess.dp.getAllArea()
    }
    
    // MARK: tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrArea.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcaCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrArea[indexPath.row].name
        cell?.imageView?.image = DataProcess.dp.loadImage(img: m_arrArea[indexPath.row].img)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewArea") as! VCViewArea
        vc.m_area = m_arrArea[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let d = m_arrArea[indexPath.row]
            
            if DataProcess.dp.getPositionByArea(id: d.id).count > 0 {
                let alertCtrl = UIAlertController(title: "提示", message: "该区域包含位置，不能删除", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                alertCtrl.addAction(cancelAction)
                present(alertCtrl, animated: true, completion: nil)
                return
            }
            
            DataProcess.dp.deleteArea(area: d)
            m_arrArea.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: ui actions
    func add() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vcEditArea = sb.instantiateViewController(withIdentifier: "VCEditArea")
        self.navigationController?.pushViewController(vcEditArea, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        m_arrArea = DataProcess.dp.getAllArea()
        tableView.reloadData()
    }
}
