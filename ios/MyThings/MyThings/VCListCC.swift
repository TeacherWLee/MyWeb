//
//  VCListCC.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/23.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

class VCListCC: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshViewDelegate {
    
    
    // -------------------------------------------------------
    // MARK: Data Members
    private var m_arrCC: [CategoryCollection]!                  //< 分类组数据源
    private var m_tableview: UITableView!
    
    
    // -------------------------------------------------------
    // MARK: App Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---- navigation controller ----
        self.navigationItem.title = "分类组"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // ---- tableview delegate ----
        m_tableview = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(m_tableview)
        m_tableview.tableFooterView = UIView()
        m_tableview.delegate = self
        m_tableview.dataSource = self
        
        // ---- data procress ----
        m_arrCC = DP.dp.getCCs(state: .STATE_NORMAL)
    }
    
    
    // -------------------------------------------------------
    //MARK: Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrCC.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vc_list_cc_cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrCC[indexPath.row].name
        cell?.imageView?.image = DP.dp.loadImage(img: m_arrCC[indexPath.row].img)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = VCEditCC(cc: m_arrCC[indexPath.row], editType: .EDIT_TYPE_VIEW)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cc = m_arrCC[indexPath.row]
            
            if DP.dp.getCategoryCnt(inCC: cc, state: .STATE_NORMAL) > 0 {
                alertTip(vc: self, message: "该分类组包含分类，不能删除")
                return
            }

            if DP.dp.deleteCC(cc: cc) != 0 {
                tipLabel(view: self.view, strTip: "删除类别组 \(cc.name) 成功")
                m_arrCC.remove(at: indexPath.row)
                m_tableview.reloadData()
            } else {
                tipLabel(view: self.view, strTip: "删除类别组 \(cc.name) 失败")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_CELL_H
    }

    
    // -------------------------------------------------------
    // MARK: UI Actions
    @objc func add() {
        let vc = VCEditCC()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // -------------------------------------------------------
    // MARK: RefreshViewDelegate
    func refresh(p: Any?) {
        m_arrCC = DP.dp.getCCs(state: .STATE_NORMAL)
        m_tableview.reloadData()
    }
}
