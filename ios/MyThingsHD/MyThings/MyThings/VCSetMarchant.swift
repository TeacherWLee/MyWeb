//
//  VCSetMarchant.swift
//  MyThings
//
//  Created by LiWei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCSetMarchant: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Data Member
    var m_arrMarchant:[Marchant]!       // 分类组数据源

    // MARK: app delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航控制器
        self.navigationItem.title = "商家"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // tableview delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        m_arrMarchant = DataProcess.dp.getAllMarchant()
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {       // 设置行数
        return m_arrMarchant.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {    // 设置每行的单元格cell
        let strID = "smCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        cell?.textLabel?.text = m_arrMarchant[indexPath.row].name
        cell?.imageView?.image = DataProcess.dp.loadImage(img: m_arrMarchant[indexPath.row].img)
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {    // 设置选中某单元格后的行为
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewMarchant") as! VCViewMarchant
        vc.m_marchant = m_arrMarchant[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {    // 设置滑动删除某单元格
        if editingStyle == .delete {
            let d = m_arrMarchant[indexPath.row]
            
            if DataProcess.dp.getThingsByMarchant(id: d.id).count > 0 {
                let alertCtrl = UIAlertController(title: "提示", message: "该商家包含物品，不能删除", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                alertCtrl.addAction(cancelAction)
                present(alertCtrl, animated: true, completion: nil)
                return
            }
            
            DataProcess.dp.deleteMarchant(marchant: d)
            m_arrMarchant.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {    // 修改TableView行高
        return 70
    }
    
    // MARK: Actions
    func add() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditMarchant")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        m_arrMarchant = DataProcess.dp.getAllMarchant()
        tableView.reloadData()
    }
}
