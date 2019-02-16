//
//  VCPosition.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import UIKit

class VCPosition: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: data members
    var dicPosition: [Int:[Position]]!  // key是Category Collection的ID
    var arrArea: [Area]!
    
    // MARK: app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // deal data
        arrArea = [Area]()
        dicPosition = [Int:[Position]]()
        arrArea = DataProcess.dp.getAllArea()
        for item in arrArea {
            dicPosition[item.id] = [Position]()
        }
        let arrPosition = DataProcess.dp.getAllPosition()
        for item in arrPosition {
            dicPosition[item.area]?.append(item)
        }
        
        // navigation controller
        self.navigationItem.title = "位置（\(arrPosition.count)）"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrArea.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrArea[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let ID = arrArea[section].id
        return (dicPosition[ID]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "vcpID"
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        cell?.accessoryType = .disclosureIndicator
        
        let ID = arrArea[indexPath.section].id
        let arrData = dicPosition[ID]
        cell?.textLabel?.text = arrData?[indexPath.row].name
        
        var img = DataProcess.dp.loadImage(img: (arrData?[indexPath.row].img)!)
        if img == nil {
            img = UIImage(named: "default_position")
        }
        cell?.imageView?.image = img
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ID = arrArea[indexPath.section].id
            let position = dicPosition[ID]?[indexPath.row]
            if position != nil {
                if DataProcess.dp.getThingsByPosition(id: (position?.id)!).count > 0 {
                    let alertCtrl = UIAlertController(title: "提示", message: "该位置包含物品，不能删除", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                    alertCtrl.addAction(cancelAction)
                    present(alertCtrl, animated: true, completion: nil)
                    return
                }
                DataProcess.dp.deletePosition(position: position!)
                dicPosition[ID]?.remove(at: indexPath.row)
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {     // 选中单元格代理
        // 获取当前单元格的Category
        let id = arrArea[indexPath.section].id
        let arrPosition = dicPosition[id]
        let position = arrPosition?[indexPath.row]
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCViewPosition") as! VCViewPosition
        vc.m_position = position
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: UI Actions
    func add() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VCEditPosition") as! VCEditPosition
        vc.isEdit = false
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: function members
    func refresh() {
        for (key, _) in dicPosition {
            dicPosition[key]?.removeAll()
        }

        let arrPosition = DataProcess.dp.getAllPosition()
        for item in arrPosition {
            dicPosition[item.area]?.append(item)
        }
        
        tableView.reloadData()
    }
}
