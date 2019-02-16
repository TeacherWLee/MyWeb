//
//  VCPosition.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/11.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

class VCMainPosition: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshViewDelegate {
    
    // ---------------------------------------------------------------------------------
    // MARK: Data Members
    var m_dicPosition: [Int:[Position]] = [:]        // key是Area的ID
    var m_arrArea: [Area] = []
    var m_tableView: UITableView
    
    
    // ------ initial ------
    init() {
        m_tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: App Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        // ---- 导航栏 ----
        self.navigationItem.title = "位置"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        // ---- 表视图 ----
        m_tableView = UITableView(frame: self.view.bounds, style: .grouped)
        m_tableView.delegate = self
        m_tableView.dataSource = self
        m_tableView.sectionHeaderHeight = TABLE_SECTION_H
        m_tableView.sectionFooterHeight = 0
        self.view.addSubview(m_tableView)
        
        // ---- load data ----
        loadData()
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: Function Members
    // ------ deal data ------
    func loadData() {
        m_arrArea.removeAll()
        m_dicPosition.removeAll()
        
        m_arrArea = DP.dp.getAreas(state: .STATE_NORMAL)
        for item in m_arrArea {
            m_dicPosition[item.id] = DP.dp.getPositions(inArea: item, state: .STATE_NORMAL)
        }
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return m_arrArea.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (m_dicPosition[m_arrArea[section].id]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vc_main_position"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_dicPosition[m_arrArea[indexPath.section].id]?[indexPath.row].name
        
        var img = DP.dp.loadImage(img: (m_dicPosition[m_arrArea[indexPath.section].id]?[indexPath.row].img)!)
        //if img == nil { img = UIImage(named: "default_position") }
        cell?.imageView?.image = img
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let position = m_dicPosition[m_arrArea[indexPath.section].id]?[indexPath.row]
            if position != nil {
                if DP.dp.getThingsCnt(inPosition: position!, state: .STATE_ALL) > 0 {
                    alertTip(vc: self, message: "该位置包含物品，不能删除")
                    return
                }
                
                if DP.dp.deletePosition(position: position!) != 0 {
                    tipLabel(view: self.view, strTip: "删除位置 \(position!.name) 成功")
                    m_dicPosition[m_arrArea[indexPath.section].id]?.remove(at: indexPath.row)
                    tableView.reloadData()
                } else {
                    tipLabel(view: self.view, strTip: "删除位置 \(position!.name) 失败")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     // 选中单元格代理
        let position = m_dicPosition[m_arrArea[indexPath.section].id]?[indexPath.row]
        let vcListThings = VCListThings(position: position!)
        vcListThings.hidesBottomBarWhenPushed = true
        vcListThings.delegate = self
        self.navigationController?.pushViewController(vcListThings, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: TABLE_SECTION_H))
        let label  = UILabel(frame: CGRect(x: CGFloat(SAFE_AREA_MARGIN), y: 10, width: tableView.bounds.size.width, height: TABLE_SECTION_H-10))
        label.text = m_arrArea[section].name
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_CELL_H
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: UI Actions
    @objc func add() {
        let vcEditPosition = VCEditPosition()
        vcEditPosition.hidesBottomBarWhenPushed = true
        vcEditPosition.delegate = self
        self.navigationController?.pushViewController(vcEditPosition, animated: true)
    }
    
    
    // ------ Refresh View Delegate ------
    func refresh(p: Any?) {
        loadData()
        m_tableView.reloadData()
    }
}
