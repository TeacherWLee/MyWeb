//
//  VCCategory.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/11.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

enum TABLE_SECTION_STATE: Int {
    case UNFOLD = 0                 // TableView Section 折叠状态
    case FOLD = 1                   // TableView Section 展开状态
}

class VCMainCategory: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshViewDelegate {
    
    // ---------------------------------------------------------------------------------
    // MARK: Data Members
    var m_dicCategory: [Int:[Category]] = [:]           // key是Category Collection的ID
    var m_arrCC: [CategoryCollection] = []              // 分类组的数组
    var m_tableView: UITableView
    let m_categoryType: ListType                        // 显示分类的类型
    var m_arrSectionState: [TABLE_SECTION_STATE] = []   // TableView每个Section展开或折叠状态
    
    
    // ---------------------------------------------------------------------------------
    // MARK: Initial
    init() {
        m_tableView = UITableView()
        m_categoryType = .LIST_TYPE_NORMAL
        super.init(nibName: nil, bundle: nil)
    }
    
    init(categoryType: ListType) {
        m_tableView = UITableView()
        m_categoryType = categoryType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: App Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---- navigation -----
        if m_categoryType == .LIST_TYPE_NORMAL {
            self.navigationItem.title = "分类"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        } else if m_categoryType == .LIST_TYPE_STORAGE {
            self.navigationItem.title = "旧物保留物品"
        } else if m_categoryType == .LIST_TYPE_DELETE {
            self.navigationItem.title = "删除的物品"
        }
        
        // ----- deal data -----
        loadData()
        
        // ---- tableview ----
        m_tableView = UITableView(frame: self.view.bounds, style: .grouped)
        m_tableView.delegate = self
        m_tableView.dataSource = self
        m_tableView.sectionHeaderHeight = TABLE_SECTION_H
        m_tableView.sectionFooterHeight = 0
        self.view.addSubview(m_tableView)
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: Function Members
    // ------ deal data ------
    func loadData() {
        m_arrCC.removeAll()
        m_dicCategory.removeAll()
        
        m_arrCC = DP.dp.getCCs(state: .STATE_NORMAL)
        for item in m_arrCC {
            m_dicCategory[item.id] = DP.dp.getCategorys(inCC: item, state: .STATE_NORMAL)
        }
        
        if m_arrSectionState.isEmpty {
            m_arrSectionState = [TABLE_SECTION_STATE](repeating: TABLE_SECTION_STATE.FOLD, count: m_arrCC.count)
        }
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return m_arrCC.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (m_dicCategory[m_arrCC[section].id]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ---- 复用cell ----
        var strID = "vc_main_category_normal_cell"
        if m_categoryType == .LIST_TYPE_STORAGE {
            strID = "vc_main_category_storage_cell"
        } else if m_categoryType == .LIST_TYPE_DELETE {
            strID = "vc_main_category_delete_cell"
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil { cell = UITableViewCell(style: .default, reuseIdentifier: strID) }
        
        if m_arrSectionState[indexPath.section] == .UNFOLD {
            cell?.textLabel?.text = ""
            cell?.accessoryType = .none
            return cell!
        }
        
        cell?.accessoryType = .disclosureIndicator

        let category = m_dicCategory[m_arrCC[indexPath.section].id]?[indexPath.row] //< 获取分类信息
        
        var count: Int = DP.dp.getThingsCnt(inCategory: category!, state: .STATE_NORMAL) //< 获取不同分类的物品数量
        if m_categoryType == .LIST_TYPE_STORAGE { count = DP.dp.getThingsCnt(inCategory: category!, state: .STATE_STORAGE)
        } else if m_categoryType == .LIST_TYPE_DELETE { count = DP.dp.getThingsCnt(inCategory: category!, state: .STATE_STORAGE) }

        let maxcount: Int = category!.maxcount

        // ---- cell label ----
        if m_categoryType == .LIST_TYPE_NORMAL {
            var cellLabel = "\(category!.name)（\(count)/\(maxcount)）"
            cell?.textLabel?.textColor = UIColor.black
            
            if (maxcount == 0) {        // 不受最大数量限制
                cellLabel = "\(category!.name)（\(count)）"
            } else if (count > maxcount) {   // 物品数超过本分类的最大数量
                cell?.textLabel?.textColor = UIColor.red
            }
            
            cell?.textLabel?.text = cellLabel
        } else if m_categoryType == .LIST_TYPE_STORAGE || m_categoryType == .LIST_TYPE_DELETE {
            cell?.textLabel?.text = "\(category!.name)（\(count)）"
        }
        
        let img = DP.dp.loadImage(img: category!.img)  //< image
        // if img == nil { img = UIImage(named: "default_category") }
        cell?.imageView?.image = img
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = m_dicCategory[m_arrCC[indexPath.section].id]?[indexPath.row]
            if category != nil {
                if DP.dp.getThingsCnt(inCategory: category!, state: .STATE_ALL) > 0 {
                    alertTip(vc: self, message: "该分类包含物品，不能删除")
                    return
                }
                
                if DP.dp.deleteCategory(category: category!) != 0 {
                    tipLabel(view: self.view, strTip: "删除分类 \(category!.name) 成功")
                    m_dicCategory[m_arrCC[indexPath.section].id]?.remove(at: indexPath.row)
                    tableView.reloadData()
                } else {
                    tipLabel(view: self.view, strTip: "删除分为 \(category!.name) 失败")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     // 选中单元格代理
        let category = m_dicCategory[m_arrCC[indexPath.section].id]?[indexPath.row] //< 获取当前单元格的Category
        
        // 创建物品显示视图控制器并加到导航控制器中
        var vcListThings = VCListThings(category: category!, thingListType: .THINGLIST_SPECIAL_CATEGORY)
        if m_categoryType == .LIST_TYPE_STORAGE {
            vcListThings = VCListThings(category: category!, thingListType: .THINGLIST_SPECIAL_CATEGORY_STORAGE)
        } else if m_categoryType == .LIST_TYPE_DELETE {
            vcListThings = VCListThings(category: category!, thingListType: .THINGLIST_SPECIAL_CATEGORY_DELETE)
        }
        vcListThings.hidesBottomBarWhenPushed = true
        vcListThings.delegate = self
        self.navigationController?.pushViewController(vcListThings, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if m_arrSectionState[indexPath.section] == .UNFOLD { return 0
        } else { return TABLE_CELL_H }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: TABLE_SECTION_H))
        view.isUserInteractionEnabled = true
        view.tag = 100 + section
        let label  = UILabel(frame: CGRect(x: CGFloat(SAFE_AREA_MARGIN), y: 10, width: tableView.bounds.size.width, height: TABLE_SECTION_H-10))
        label.text = m_arrCC[section].name
        view.addSubview(label)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sectionTitleTapGestureAction(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: UI Actions
    @objc func add() {
        let vcEditCategory = VCEditCategory()
        vcEditCategory.hidesBottomBarWhenPushed = true
        vcEditCategory.delegate = self
        self.navigationController?.pushViewController(vcEditCategory, animated: true)
    }
    
    @objc func sectionTitleTapGestureAction(tapGesture: UITapGestureRecognizer) {
        let index: Int = tapGesture.view!.tag % 100
        let indexSet = IndexSet(integer: index)
        
        if m_arrSectionState[index] == .UNFOLD {
            m_arrSectionState[index] = .FOLD
        } else {
            m_arrSectionState[index] = .UNFOLD
        }
        
        //m_tableView.reloadData()
        m_tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
    }
    
    
    // ------ Refresh View Delegate ------
    func refresh(p: Any?) {
        loadData()
        m_tableView.reloadData()
    }
}
