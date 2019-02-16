//
//  VCSetCC.swift
//  MyThings
//
//  Created by LiWei on 2017/1/11.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCSetCC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data members
    var m_arrCC:[CategoryCollection]!       // 分类组数据源

    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation controller
        self.navigationItem.title = "分类组"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
   
        // tableview delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        m_arrCC = DataProcess.dp.getAllCC()
    }
    
    // MARK: tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrCC.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcsccCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrCC[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewCC") as! VCViewCC
        vc.m_CC = m_arrCC[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cc = m_arrCC[indexPath.row]
            
            if DataProcess.dp.getCategoryByCC(id: cc.id).count > 0 {
                let alertCtrl = UIAlertController(title: "提示", message: "该分类组包含分类，不能删除", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                alertCtrl.addAction(cancelAction)
                present(alertCtrl, animated: true, completion: nil)
                return
            }
            
            DataProcess.dp.deleteCC(cc: cc)
            m_arrCC.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: ui actions
    func add() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditCC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        m_arrCC = DataProcess.dp.getAllCC()
        tableView.reloadData()
    }
}
