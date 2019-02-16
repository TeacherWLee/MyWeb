//
//  VCListArea.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/28.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

class VCListArea: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshViewDelegate {
    
    // -------------------------------------------------------
    // MARK: Data Members
    private var m_arrArea:[Area]!                   //< 区域数据源
    private var m_tableview: UITableView!
    
    
    // -------------------------------------------------------
    // MARK: App Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---- navigation controller ----
        self.navigationItem.title = "区域"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // ---- tableview delegate ----
        m_tableview = UITableView(frame: self.view.bounds, style: .plain)
        self.view.addSubview(m_tableview)
        m_tableview.tableFooterView = UIView()
        m_tableview.delegate = self
        m_tableview.dataSource = self
        
        // ---- data procress ----
        m_arrArea = DP.dp.getAreas(state: .STATE_NORMAL)
    }
    
    
    // -------------------------------------------------------
    //MARK: Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrArea.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vc_list_area_cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrArea[indexPath.row].name
        cell?.imageView?.image = DP.dp.loadImage(img: m_arrArea[indexPath.row].img)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = VCEditArea(area: m_arrArea[indexPath.row], editType: .EDIT_TYPE_VIEW)
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let area = m_arrArea[indexPath.row]
            
            if DP.dp.getPositionCnt(inArea: area, state: .STATE_NORMAL) > 0 {
                alertTip(vc: self, message: "该区域包含位置，不能删除")
                return
            }
            
            if DP.dp.deleteArea(area: area) != 0 {
                tipLabel(view: self.view, strTip: "删除区域 \(area.name) 成功")
                m_arrArea.remove(at: indexPath.row)
                tableView.reloadData()
            } else {
                tipLabel(view: self.view, strTip: "删除区域 \(area.name) 失败")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_CELL_H
    }
    
    
    // -------------------------------------------------------
    // MARK: UI Actions
    @objc func add() {
        let vc = VCEditArea()
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    // -------------------------------------------------------
    // MARK: Function Members
    func refresh(p: Any?) {
        m_arrArea = DP.dp.getAreas(state: .STATE_NORMAL)
        m_tableview.reloadData()
    }
}
