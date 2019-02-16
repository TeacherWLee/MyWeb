//
//  VCCategory.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import UIKit

// 分类视图控制器
class VCCategory: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: data members
    var dicCategory: [Int:[Category]]!  // key是Category Collection的ID
    var arrCC: [CategoryCollection]!
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // dealData
        arrCC = [CategoryCollection]()
        dicCategory = [Int:[Category]]()
        arrCC = DataProcess.dp.getAllCC()
        for item in arrCC {
//            dicCategory[item.id] = [Category]()
            dicCategory[item.id] = DataProcess.dp.getCategoryByCC(id: item.id)
        }
//        let arrCategory = DataProcess.dp.getAllCategory()
//        for item in arrCategory {
//            dicCategory[item.cc]?.append(item)
//        }
        
        // navigation controller
        //self.navigationItem.title = "分类（\(arrCategory.count)）"
        self.navigationItem.title = "分类"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCC.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrCC[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ID = arrCC[section].id
        return (dicCategory[ID]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vccID"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        cell?.accessoryType = .disclosureIndicator

        let ccID = arrCC[indexPath.section].id
        let arrCategory = dicCategory[ccID]
        let category = arrCategory?[indexPath.row]
        
        let arrThingsTmp = DataProcess.dp.getThingsByCategory(id: (arrCategory?[indexPath.row].id)!)
        let count: Int = arrThingsTmp.count
        let maxcount: Int = category!.maxcount
        
        var cellLabel = "\(category!.name)（\(count)/\(maxcount)）"
        cell?.textLabel?.textColor = UIColor.black
        
        if (maxcount == 0) {        // 不受最大数量限制
            cellLabel = "\(category!.name)（\(count)）"
        } else if (count > maxcount) {   // 物品数超过本分类的最大数量
            cell?.textLabel?.textColor = UIColor.red
        }

        cell?.textLabel?.text = cellLabel
        
        var img = DataProcess.dp.loadImage(img: (arrCategory?[indexPath.row].img)!)
        if img == nil {
            img = UIImage(named: "default_category")
        }
        cell?.imageView?.image = img
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ID = arrCC[indexPath.section].id
            let category = dicCategory[ID]?[indexPath.row]
            if category != nil {
                if DataProcess.dp.getThingsByCategory(id: (category?.id)!).count > 0 {
                    let alertCtrl = UIAlertController(title: "提示", message: "该分类包含物品，不能删除", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                    alertCtrl.addAction(cancelAction)
                    present(alertCtrl, animated: true, completion: nil)
                    return
                }
                DataProcess.dp.deleteCategory(category: category!)
                dicCategory[ID]?.remove(at: indexPath.row)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     // 选中单元格代理
        // 获取当前单元格的Category
        let id = arrCC[indexPath.section].id
        let arrCategory = dicCategory[id]
        let category = arrCategory?[indexPath.row]
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewCategory") as! VCViewCategory
        vc.m_category = category
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: UI Actions
    func add() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditCategory") as! VCEditCategory
        vc.isEdit = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: function members
    func refresh() {
        for (key, _) in dicCategory {
            dicCategory[key]?.removeAll()
        }
        
        let arrCategory = DataProcess.dp.getAllCategory()
        for item in arrCategory {
            dicCategory[item.cc]?.append(item)
        }
        
        tableView.reloadData()
    }
}
