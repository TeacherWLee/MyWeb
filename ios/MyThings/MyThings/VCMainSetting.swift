//
//  VCSetting.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/11.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit


////////////////////////////////////////////////////////////////////////////////////
//////  主页面的设置视图
////////////////////////////////////////////////////////////////////////////////////
class VCMainSetting: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // ------ MARK: Data Members ------
    let m_arrSectionTitles: [String] = ["基本设置", "查看物品", "数据管理", "查看已删除条目"]
    let m_arrCellTitles:[[String]] = [["分类组设置", "区域设置", "用户设置", "商家设置"], ["全部物品", "旧物保留物品（列表）", "旧物保留物品（分类）", "全新备用物品", "过期物品", "丢失物品"], ["数据同步", "清理照片", "执行SQL"],["已删除物品（列表）", "已删除物品（分类）", "已删除的其他条目"]]
    
    
    // controller delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation
        self.navigationItem.title = "设置"
        
        // tableView
        let tableView = UITableView(frame: UIScreen.main.bounds, style: .grouped)
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.sectionHeaderHeight = TABLE_SECTION_H
        tableView.sectionFooterHeight = 0
    }
    
    
    // ------ MARK: TableView ------
    func numberOfSections(in tableView: UITableView) -> Int {
        return m_arrSectionTitles.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrCellTitles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vc_main_setting"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = m_arrCellTitles[indexPath.section][indexPath.row]

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {                     // 设置用户选中一行行为
        if indexPath.section == 0 {
            if indexPath.row == 0 { // 设置分类组
                let vc = VCListCC()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 { // 设置区域
                let vc = VCListArea()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 { // 设置所有者
                let vc = VCListOwner()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 3 { // 设置商家
                let vc = VCListMarchant()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 { // 全部物品
                let vc = VCListThings(thingListType: .THINGLIST_ALL)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 { // 旧物保留物品（列表）
                let vc = VCListThings(thingListType: .THINGLIST_STORAGE)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 { // 旧物保留物品（分类）
                let vc = VCMainCategory(categoryType: .LIST_TYPE_STORAGE)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 3 { // 全新备用的物品
                let vc = VCListThings(thingListType: .THINGLIST_RESERVE)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 4 { // 过期的物品
                let vc = VCListThings(thingListType: .THINGLIST_EXPEIR)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 5 { // 丢失的物品
                let vc = VCListThings(thingListType: .THINGLIST_LOST)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 { // 数据同步
                let vc = VCToolSyncData()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 { // 清理照片
                let arrUnusedImgs = DP.dp.retrieveMissedOrUnusedImgs().unusedImgs
                for unusedImg in arrUnusedImgs {
                    _ = DP.dp.deleteImage(img: unusedImg)
                }
                alertTip(vc: self, message: "已删除未用图片\(arrUnusedImgs.count)张")
            } else if indexPath.row == 2 { // 执行SQL
                let vc = VCToolExeSQL()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 3 { // 删除数据库
                DP.dp.deleteDB()
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {             // 已删除物品（列表）
                let vc = VCListThings(thingListType: .THINGLIST_DELETE)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {      // 已删除物品（分类）
                let vc = VCMainCategory(categoryType: .LIST_TYPE_DELETE)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 {      // 已删除分类组、分类、区域、位置、商家和用户
                let vc = VCListDeletedItem()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_ROW_H_LIST
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TABLE_SECTION_H
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: TABLE_SECTION_H))
        let label  = UILabel(frame: CGRect(x: CGFloat(SAFE_AREA_MARGIN), y: 10, width: tableView.bounds.size.width, height: TABLE_SECTION_H - 10))
        view.addSubview(label)
        label.text = m_arrSectionTitles[section]
        return view
    }

    public func refresh() {
        
    }
}
