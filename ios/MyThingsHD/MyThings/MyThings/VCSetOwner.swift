//
//  VCSetOwner.swift
//  MyThings
//
//  Created by Li Wei on 2017/1/12.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import UIKit

class VCSetOwner: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data members
    var m_arrOwner: [Owner]!
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation controller
        self.navigationItem.title = "用户"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // tableview delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        m_arrOwner = DataProcess.dp.getAllOwner()
    }
    
    // MARK: tableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrOwner.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcsoCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrOwner[indexPath.row].name
        var img = DataProcess.dp.loadImage(img: m_arrOwner[indexPath.row].img)
        
        if img == nil {
            if m_arrOwner[indexPath.row].name == "全体成员" {
                img = UIImage(named: "all_owner")
            } else if m_arrOwner[indexPath.row].name == "李巍" {
                img = UIImage(named: "liwei")
            } else if m_arrOwner[indexPath.row].name == "于砚卓" {
                img = UIImage(named: "yuyanzhuo")
            } else if m_arrOwner[indexPath.row].name == "李季耳" {
                img = UIImage(named: "lijier")
            }
        }
        
        cell?.imageView?.image = img
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewOwner") as! VCViewOwner
        vc.m_owner = m_arrOwner[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let d = m_arrOwner[indexPath.row]
            
            if DataProcess.dp.getThingsByOwner(id: d.id).count > 0 {
                let alertCtrl = UIAlertController(title: "提示", message: "该用户包含物品，不能删除", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                alertCtrl.addAction(cancelAction)
                present(alertCtrl, animated: true, completion: nil)
                return
            }
            
            DataProcess.dp.deleteOwner(owner:d)
            m_arrOwner.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: ui actions
    func add() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditOwner")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        m_arrOwner = DataProcess.dp.getAllOwner()
        tableView.reloadData()
    }
}
