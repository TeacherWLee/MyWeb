//
//  VCAllThings.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import UIKit

class VCAllThings: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: data members
    var m_arrThings:[Thing]!            // 全部物品、datasource
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView delegate
        tableView.delegate = self
        tableView.dataSource = self

        m_arrThings = DataProcess.dp.getAllThings()
        tableView.reloadData()
        
        // navigation controller
        self.navigationItem.title = "所有物品（\(m_arrThings.count)）"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
    }
    
    // MARK: TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {       // 行数
        return m_arrThings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {    // 每行单元格
        let strID = "vcatCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        return formatCell(cell: cell!, thing: m_arrThings[indexPath.row])
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
    
    // MARK: UI Actions
    @IBAction func btnAddThing(_ sender: UIButton) {    //添加物品按钮事件动作
//        var arrData = DataProcess.dp.getAllArea()
//        for item in arrData {
//            var newImgPath: String = ""
//            let arrImgPathSplit = item.img.characters.split(separator: "/")
//            if arrImgPathSplit.count > 0 {
//                newImgPath = String(arrImgPathSplit[arrImgPathSplit.count-1])
//            }
//            
//            let sql = "update area set img='\(newImgPath)' where id='\(item.id)'"
//            let db = SQLiteDB.sharedInstance
//            let rst = db.execute(sql: sql)
//            print("execute sql: \(sql), result is: \(rst)")
//        }
        
//        DataProcess.dp.deleteDB()
        
        
        
        
        
        add()
    }
    
    func add() {    // 添加新物品
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vcEditThings: VCEditThings = sb.instantiateViewController(withIdentifier: "VCEditThing") as! VCEditThings
        vcEditThings.isEdit = false
        self.navigationController?.pushViewController(vcEditThings, animated: true)
    }
    
    // MARK: function members
    func refresh() {    // 重新加载数据
        m_arrThings = DataProcess.dp.getAllThings()
        tableView.reloadData()
    }
}
