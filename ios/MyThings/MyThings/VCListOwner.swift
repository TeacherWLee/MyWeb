//
//  VCListOwner.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/28.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

class VCListOwner: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshViewDelegate {
    
    // -------------------------------------------------------
    // MARK: Data Members
    private var m_arrOwner:[Owner]!       // 所有者数据源
    private var m_tableview: UITableView!
    
    
    // -------------------------------------------------------
    // MARK: App Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---- navigation controller ----
        self.navigationItem.title = "所有者"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // ---- tableview delegate ----
        m_tableview = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(m_tableview)
        m_tableview.tableFooterView = UIView()
        m_tableview.delegate = self
        m_tableview.dataSource = self
        
        // ---- data procress ----
        m_arrOwner = DP.dp.getOwners(state: .STATE_NORMAL)
    }
    
    
    // -------------------------------------------------------
    //MARK: Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrOwner.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vc_list_owner_cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrOwner[indexPath.row].name
        cell?.imageView?.image = DP.dp.loadImage(img: m_arrOwner[indexPath.row].img)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = VCEditOwner(owner: m_arrOwner[indexPath.row], editType: .EDIT_TYPE_VIEW)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let owner = m_arrOwner[indexPath.row]
            
            if DP.dp.getThingsCnt(inOwner: owner, state: .STATE_NORMAL) > 0 ||
                DP.dp.getThingsCnt(inOwner: owner, state: .STATE_STORAGE) > 0 ||
                DP.dp.getThingsCnt(inOwner: owner, state: .STATE_RESERVE) > 0 {
                alertTip(vc: self, message: "该所有者包含物品（正常、保留或备用），不能删除")
                return
            }
            
            if DP.dp.deleteOwner(owner: owner) != 0 {
                tipLabel(view: self.view, strTip: "删除所有者 \(owner.name) 成功")
                m_arrOwner.remove(at: indexPath.row)
                tableView.reloadData()
            } else {
                tipLabel(view: self.view, strTip: "删除所有者 \(owner.name) 失败")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_CELL_H
    }
    
    
    // -------------------------------------------------------
    // MARK: UI Actions
    @objc func add() {
        let vc = VCEditOwner()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // -------------------------------------------------------
    // MARK: Function Members
    func refresh(p: Any?) {
        m_arrOwner = DP.dp.getOwners(state: .STATE_NORMAL)
        m_tableview.reloadData()
    }
}
