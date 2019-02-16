//
//  VCListThings.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/20.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

// 物品列表视图控制器
class VCListThings: UIViewController, UITableViewDelegate, UITableViewDataSource, RefreshViewDelegate {
    
    // ---------------------------------------------------------------------------------
    // MARK: Data Members
    public var delegate: RefreshViewDelegate!                           // 刷新内容代理对象
    private var m_arrThings:[Thing] = []                                // 要显示的物品列表
    private var m_thingListType:ThingListType = .THINGLIST_DEFAULT      // 显示物品列表类型
    private var popMenu:SwiftPopMenu!                                   // 弹出菜单
    private var m_inputCategory: Category?                              // 输入的分类变量
    private var m_inputPosition: Position?                              // 输入的位置变量
    private var m_tableView: UITableView
    
    
    // ---------------------------------------------------------------------------------
    // MARK: Initial
    init(category: Category, thingListType: ThingListType) {
        m_inputCategory = category
        m_thingListType = thingListType
        m_tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(position: Position) {
        m_inputPosition = position
        m_thingListType = .THINGLIST_SPECIAL_POSITION
        m_tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(thingListType: ThingListType) {
        m_thingListType = thingListType
        m_tableView = UITableView(frame: UIScreen.main.bounds, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: App Delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ------ data member initial ------
        loadData()
        
        // ------ navigation ------
        if m_thingListType == .THINGLIST_SPECIAL_CATEGORY || m_thingListType == .THINGLIST_SPECIAL_POSITION {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop_menu"), style: .plain, target: self, action: #selector(self.showMenu))
        }
        
        // ------ table view -------
        m_tableView.delegate = self
        m_tableView.dataSource = self
        m_tableView.tableFooterView = UIView()
        self.view.addSubview(m_tableView)
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: Function Members
    private func loadData() {
        m_arrThings.removeAll()
        
        switch m_thingListType {
        case .THINGLIST_SPECIAL_CATEGORY:
            m_arrThings = DP.dp.getThings(byCategory: m_inputCategory!, state: .STATE_NORMAL)
            self.navigationItem.title = "\(m_inputCategory!.name) (\(m_arrThings.count))"
        case .THINGLIST_SPECIAL_CATEGORY_STORAGE:
            m_arrThings = DP.dp.getThings(byCategory: m_inputCategory!, state: .STATE_STORAGE)
            self.navigationItem.title = "\(m_inputCategory!.name) (\(m_arrThings.count))"
        case .THINGLIST_SPECIAL_CATEGORY_DELETE:
            m_arrThings = DP.dp.getThings(byCategory: m_inputCategory!, state: .STATE_DELETE)
            self.navigationItem.title = "\(m_inputCategory!.name) (\(m_arrThings.count))"
        case .THINGLIST_SPECIAL_POSITION:
            m_arrThings = DP.dp.getThings(byPosition: m_inputPosition!, state: .STATE_NORMAL)
            self.navigationItem.title = "\(m_inputPosition!.name)"
        case .THINGLIST_STORAGE:
            m_arrThings = DP.dp.getThings(state: .STATE_STORAGE)
            self.navigationItem.title = "保留的物品"
        case .THINGLIST_RESERVE:
            m_arrThings = DP.dp.getThings(state: .STATE_RESERVE)
            self.navigationItem.title = "备用的物品"
        case .THINGLIST_ALL:
            m_arrThings = DP.dp.getThings(state: .STATE_ALL)
            self.navigationItem.title = "所有物品"
        case .THINGLIST_DELETE:
            m_arrThings = DP.dp.getThings(state: .STATE_DELETE)
            self.navigationItem.title = "已删除物品"
        case .THINGLIST_LOST:
            m_arrThings = DP.dp.getThings(state: .STATE_LOST)
            self.navigationItem.title = "丢失的物品"
        case .THINGLIST_EXPEIR:
            let arrThings = DP.dp.getThings(state: .STATE_ALL)
            for thing in arrThings {
                if Date() > thing.expeir && thing.state != DataState.STATE_DELETE.rawValue {
                    m_arrThings.append(thing)
                }
            }
            self.navigationItem.title = "过期物品"
        default:
            print("out of range.")
        }
    }
    
    public func setNewCategoty(newCategory: Category) {
        m_inputCategory = newCategory
        self.navigationItem.title = "\(m_inputCategory!.name) (\(m_arrThings.count))"
    }
    
    public func setNewPosition(newPosition: Position) {
        m_inputPosition = newPosition
        self.navigationItem.title = "\(m_inputPosition!.name) (\(m_arrThings.count))"
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return m_arrThings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // ---- reuse cell ----
        var strID = "vc_list_thing_category_normal_cell"
        if m_thingListType == .THINGLIST_ALL {
            strID = "vc_list_thing_all_cell"
        } else if m_thingListType == .THINGLIST_SPECIAL_CATEGORY_STORAGE {
            strID = "vc_list_thing_category_storage_cell"
        } else if m_thingListType == .THINGLIST_SPECIAL_CATEGORY_DELETE {
            strID = "vc_list_thing_category_delete_cell"
        } else if m_thingListType == .THINGLIST_STORAGE {
            strID = "vc_list_thing_storage_cell"
        } else if m_thingListType == .THINGLIST_LOST {
            strID = "vc_list_thing_lost_cell"
        } else if m_thingListType == .THINGLIST_DELETE {
            strID = "vc_list_thing_delete_cell"
        } else if m_thingListType == .THINGLIST_RESERVE {
            strID = "vc_list_thing_reserve_cell"
        } else if m_thingListType == .THINGLIST_EXPEIR {
            strID = "vc_list_thing_expeir_cell"
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        // ---- deal data ----
        let thing = m_arrThings[indexPath.row]
        var strDetailTitle = ""
        
        // ---- 物品数量处理 ----
        if thing.count < 1 {           // 数量为0时
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
            strDetailTitle += "数量：0"
        }
        
        if thing.maxcount > 0 {        // 超过最大数量限制
            if thing.count > thing.maxcount {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
                strDetailTitle += "超量：\(thing.count)/\(thing.maxcount)"
            }
        }
        
        // ---- 过期日期处理 ----
        if m_thingListType == .THINGLIST_DEFAULT || m_thingListType == .THINGLIST_SPECIAL_CATEGORY || m_thingListType == .THINGLIST_SPECIAL_CATEGORY_STORAGE || m_thingListType == .THINGLIST_SPECIAL_POSITION || m_thingListType == .THINGLIST_STORAGE || m_thingListType == .THINGLIST_RESERVE || m_thingListType == .THINGLIST_ALL || m_thingListType == .THINGLIST_LOST || m_thingListType == .THINGLIST_EXPEIR {
            
            if Date() > thing.expeir {        // 超过最大日期限制
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
                if strDetailTitle == "" { strDetailTitle = "过期：\(date2String(date: thing.expeir, dateFormat: "yyyy-MM-dd"))"
                } else { strDetailTitle += "  |  过期：\(date2String(date: thing.expeir, dateFormat: "yyyy-MM-dd"))" }
            }
        }
        
        // ---- 图片处理 ----
        var img = DP.dp.loadImage(img: thing.img)
        //if img == nil { img = UIImage(named: "default_thing") }
        
        // ---- Cell 赋值 ----
        cell!.textLabel?.text = thing.name
        cell!.textLabel?.textColor = UIColor.black
        cell?.accessoryType = .disclosureIndicator
        cell?.detailTextLabel?.text = strDetailTitle
        cell?.detailTextLabel?.textColor = UIColor.red
        cell!.imageView?.image = img
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if m_thingListType == .THINGLIST_SPECIAL_CATEGORY { // 在分类查看时，显示页视图
//            // let vcPageThings = VCPageThings(things: m_arrThings, currentIndex: indexPath.row)
//            let vcEditThing = VCEditThing(thing: m_arrThings[indexPath.row], editType: .EDIT_TYPE_VIEW)
//            self.navigationController?.pushViewController(vcEditThing, animated: true)
//        } else {
        
        let vcEditThing = VCEditThing(thing: m_arrThings[indexPath.row], editType: .EDIT_TYPE_VIEW)
        vcEditThing.delegate = self
        self.navigationController?.pushViewController(vcEditThing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return THING_LIST_TABLE_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let thing = m_arrThings[indexPath.row]
            if DP.dp.setThingState(thing: thing, toState: .STATE_DELETE) != 0 {
                tipLabel(view: self.view, strTip: "删除物品 \(thing.name) 成功")
            } else {
                tipLabel(view: self.view, strTip: "删除物品 \(thing.name) 失败")
            }

            refresh(p: nil)
        }
    }
    
    
    // ---------------------------------------------------------------------------------
    // MARK: UI Action
    @objc func showMenu() {
        if m_thingListType == .THINGLIST_SPECIAL_CATEGORY {
            popMenu = SwiftPopMenu(frame:  CGRect(x: self.view.bounds.size.width - 120, y: 51, width: 115, height: 162), arrowMargin: 12)
            popMenu.popData = [(icon:"add",title:"添加物品"),
                               (icon:"view_category",title:"查看分类"),
                               (icon:"edit",title:"编辑分类")]
        } else if m_thingListType == .THINGLIST_SPECIAL_POSITION {
            popMenu = SwiftPopMenu(frame:  CGRect(x: self.view.bounds.size.width - 120, y: 51, width: 115, height: 112), arrowMargin: 12)
            popMenu.popData = [(icon:"view_position",title:"查看位置"),
                               (icon:"edit",title:"编辑位置")]
        }
        //点击菜单
        popMenu.didSelectMenuBlock = { [weak self](index:Int)->Void in
            self?.popMenu.dismiss()
            
            if self?.m_thingListType == .THINGLIST_SPECIAL_CATEGORY {
                if index == 0 { // 添加物品
                    let vc = VCEditThing(category: (self?.m_inputCategory)!)
                    vc.delegate = self
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else if index == 1 { // 查看分类
                    let vc = VCEditCategory(category: (self?.m_inputCategory)!, editType: .EDIT_TYPE_VIEW)
                    //vc.delegate = self
                    self?.navigationController?.pushViewController(vc, animated: true)
                } else if index == 2 { //编辑分类
                    let vc = VCEditCategory(category: (self?.m_inputCategory)!, editType: .EDIT_TYPE_EDIT)
                    vc.delegate = self
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            } else if self?.m_thingListType == .THINGLIST_SPECIAL_POSITION {
                if index == 0 { // 查看位置
                    let vc = VCEditPosition(position: self!.m_inputPosition!, editType: .EDIT_TYPE_VIEW)
                    //vc.delegate = self
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                if index == 1 { // 编辑位置
                    let vc = VCEditPosition(position: self!.m_inputPosition!, editType: .EDIT_TYPE_EDIT)
                    vc.delegate = self
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        popMenu.show()
    }
    
    
    // -------------------------------------------------------
    // MARK: RefreshViewDelegate
    public func refresh(p: Any?) {
//        if p != nil {
//            if m_thingListType == .THINGLIST_SPECIAL_POSITION {
//                m_inputPosition = p as? Position
//            } else if m_thingListType == .THINGLIST_SPECIAL_CATEGORY {
//                m_inputCategory = p as? Category
//            }
//        }
        
        loadData()
        m_tableView.reloadData()
        
        if delegate != nil {delegate.refresh(p: p)}
    }
}
