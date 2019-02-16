//
//  VCSearch.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import UIKit

class VCSearch: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data members
    var m_arrThings:[Thing]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        self.navigationItem.title = "搜索"
        
        m_arrThings = DataProcess.dp.getAllThings()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: ui actions
    @IBAction func btnSearchAction(_ sender: UIButton) {
        refresh()
    }
    
    // MARK: tableview delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {       // 行数
        return m_arrThings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcsCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        
        cell?.textLabel?.text = m_arrThings[indexPath.row].name
        
        if m_arrThings[indexPath.row].maxcount > 0 {        // 超过最大数量限制
            if m_arrThings[indexPath.row].count > m_arrThings[indexPath.row].maxcount {
                cell?.textLabel?.textColor = UIColor.red
                cell?.textLabel?.text = "\(m_arrThings[indexPath.row].name)（\(m_arrThings[indexPath.row].count)/\(m_arrThings[indexPath.row].maxcount)）"
            }
        }
        
        if Date().compare(m_arrThings[indexPath.row].expeir) == ComparisonResult.orderedDescending {        // 超过最大日期限制
            cell?.textLabel?.textColor = UIColor.brown
            let df = DateFormatter()
            df.locale = Locale.current
            df.dateFormat = "yyyy-MM-dd"
            let strExpeir = df.string(from: m_arrThings[indexPath.row].expeir)
            cell?.textLabel?.text = "\(m_arrThings[indexPath.row].name)（\(strExpeir)）"
        }
        
        let strCategoryName = DataProcess.dp.getCategory(id: m_arrThings[indexPath.row].category)!.name
        let strPositionName = DataProcess.dp.getPosition(id: m_arrThings[indexPath.row].position)!.name
        let strOwnerName = DataProcess.dp.getOwner(id: m_arrThings[indexPath.row].owner)!.name
        let detailText = "\(strPositionName) | \(strCategoryName) | \(strOwnerName)"
        cell?.detailTextLabel?.text = detailText
        
        var img = DataProcess.dp.loadImage(img: m_arrThings[indexPath.row].img)
        if img == nil {
            img = UIImage(named: "default_thing")
        }
        cell?.imageView?.image = img
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {    // 删除操作
            let things = m_arrThings[indexPath.row]
            DataProcess.dp.deleteThings(things: things)
            m_arrThings.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     // 选中某行，查看物品详情
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewThing") as! VCViewThings
        vc.m_thing = m_arrThings[indexPath.row]     // 参数传参
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {  // 修改TableView行高
        return 70
    }
    
    // MARK: function members
    func refresh() {    // 重新加载数据
        if tfSearch == nil {
            return
        }
        
        if tfSearch.text == "" {
            m_arrThings = DataProcess.dp.getAllThings()
        }
        
        m_arrThings = DataProcess.dp.searchThings(keyword: tfSearch.text!)
        tableView.reloadData()
    }
}
