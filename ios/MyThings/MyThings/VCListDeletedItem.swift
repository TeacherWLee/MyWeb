//
//  VCListDeletedItem.swift
//  MyThings
//
//  Created by 李巍 on 2018/1/13.
//  Copyright © 2018年 李巍. All rights reserved.
//

import UIKit

class VCListDeletedItem: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // ------ data members ------
    private var m_arrDelCC: [CategoryCollection] = []
    private var m_arrDelCategory: [Category] = []
    private var m_arrDelArea: [Area] = []
    private var m_arrDelPosition: [Position] = []
    private var m_arrDelMarchant: [Marchant] = []
    private var m_arrDelOwner: [Owner] = []
    
    private let m_arrSectionTitles = ["分类组(已删除)", "物品分类(已删除)", "区域(已删除)", "位置(已删除)", "商家(已删除)", "用户(已删除)"]
    
    
    
    // ------ controller delegate ------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---- navigation ----
        self.navigationItem.title = "已删除的数据库条目"
        

        // ---- tableview ----
        let tableView = UITableView(frame: self.view.bounds, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = TABLE_SECTION_H
        tableView.sectionFooterHeight = 0
        self.view.addSubview(tableView)
        
        
        // ---- load data ----
        loadDate()
    }
    
    
    private func loadDate() {
        m_arrDelCC = DP.dp.getCCs(state: .STATE_DELETE)
        m_arrDelCategory = DP.dp.getCategorys(state: .STATE_DELETE)
        m_arrDelArea = DP.dp.getAreas(state: .STATE_DELETE)
        m_arrDelPosition = DP.dp.getPositions(state: .STATE_DELETE)
        m_arrDelMarchant = DP.dp.getMarchants(state: .STATE_DELETE)
        m_arrDelOwner = DP.dp.getOwners(state: .STATE_DELETE)
    }
    
    
    
    // ------ tableview delegate ------
    func numberOfSections(in tableView: UITableView) -> Int {
        return m_arrSectionTitles.count;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return m_arrDelCC.count
        } else if section == 1 {
            return m_arrDelCategory.count
        } else if section == 2 {
            return m_arrDelArea.count
        } else if section == 3 {
            return m_arrDelPosition.count
        } else if section == 4 {
            return m_arrDelMarchant.count
        } else {
            return m_arrDelOwner.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vc_list_deleted"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
        }
        
        switch indexPath.section {
        case 0:
            cell?.textLabel?.text = m_arrDelCC[indexPath.row].name
            cell?.detailTextLabel?.text = "id:\(m_arrDelCC[indexPath.row].id), ct:\(date2String(date: m_arrDelCC[indexPath.row].createtime, dateFormat: "yyyyMMddhhmmss")), mt:\(date2String(date: m_arrDelCC[indexPath.row].modifytime, dateFormat: "yyyyMMddhhmmss")), st:\(m_arrDelCC[indexPath.row].state)"
            cell?.imageView?.image = DP.dp.loadImage(img: m_arrDelCC[indexPath.row].img)
        case 1:
            cell?.textLabel?.text = m_arrDelCategory[indexPath.row].name
            cell?.detailTextLabel?.text = "id:\(m_arrDelCategory[indexPath.row].id), ct:\(date2String(date: m_arrDelCategory[indexPath.row].createtime, dateFormat: "yyyyMMddhhmmss")), mt:\(date2String(date: m_arrDelCategory[indexPath.row].modifytime, dateFormat: "yyyyMMddhhmmss")), st:\(m_arrDelCategory[indexPath.row].state)"
            cell?.imageView?.image = DP.dp.loadImage(img: m_arrDelCategory[indexPath.row].img)
        case 2:
            cell?.textLabel?.text = m_arrDelArea[indexPath.row].name
            cell?.detailTextLabel?.text = "id:\(m_arrDelArea[indexPath.row].id), ct:\(date2String(date: m_arrDelArea[indexPath.row].createtime, dateFormat: "yyyyMMddhhmmss")), mt:\(date2String(date: m_arrDelArea[indexPath.row].modifytime, dateFormat: "yyyyMMddhhmmss")), st:\(m_arrDelArea[indexPath.row].state)"
            cell?.imageView?.image = DP.dp.loadImage(img: m_arrDelArea[indexPath.row].img)
        case 3:
            cell?.textLabel?.text = m_arrDelPosition[indexPath.row].name
            cell?.detailTextLabel?.text = "id:\(m_arrDelPosition[indexPath.row].id), ct:\(date2String(date: m_arrDelPosition[indexPath.row].createtime, dateFormat: "yyyyMMddhhmmss")), mt:\(date2String(date: m_arrDelPosition[indexPath.row].modifytime, dateFormat: "yyyyMMddhhmmss")), st:\(m_arrDelPosition[indexPath.row].state)"
            cell?.imageView?.image = DP.dp.loadImage(img: m_arrDelPosition[indexPath.row].img)
        case 4:
            cell?.textLabel?.text = m_arrDelMarchant[indexPath.row].name
            cell?.detailTextLabel?.text = "id:\(m_arrDelMarchant[indexPath.row].id), ct:\(date2String(date: m_arrDelMarchant[indexPath.row].createtime, dateFormat: "yyyyMMddhhmmss")), mt:\(date2String(date: m_arrDelMarchant[indexPath.row].modifytime, dateFormat: "yyyyMMddhhmmss")), st:\(m_arrDelMarchant[indexPath.row].state)"
            cell?.imageView?.image = DP.dp.loadImage(img: m_arrDelMarchant[indexPath.row].img)
        case 5:
            cell?.textLabel?.text = m_arrDelOwner[indexPath.row].name
            cell?.detailTextLabel?.text = "id:\(m_arrDelOwner[indexPath.row].id), ct:\(date2String(date: m_arrDelOwner[indexPath.row].createtime, dateFormat: "yyyyMMddhhmmss")), mt:\(date2String(date: m_arrDelOwner[indexPath.row].modifytime, dateFormat: "yyyyMMddhhmmss")), st:\(m_arrDelOwner[indexPath.row].state)"
            cell?.imageView?.image = DP.dp.loadImage(img: m_arrDelOwner[indexPath.row].img)
        default:
            print("out of range")
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: TABLE_SECTION_H))
        let label  = UILabel(frame: CGRect(x: CGFloat(SAFE_AREA_MARGIN), y: 10, width: tableView.bounds.size.width, height: TABLE_SECTION_H - 10))
        view.addSubview(label)
        label.text = m_arrSectionTitles[section]
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_ROW_H_LIST
    }
}
