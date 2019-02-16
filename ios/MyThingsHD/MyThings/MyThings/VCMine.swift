
//
//  VCMine.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import UIKit

class VCMine: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation controller
        self.navigationItem.title = "设置"
        
        // tableview delegate
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strID = "MineCell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: strID)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: strID)
        }
        
        cell?.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell?.textLabel?.text = "分类组设置"
        } else if indexPath.row == 1 {
            cell?.textLabel?.text = "区域设置"
        } else if indexPath.row == 2 {
            cell?.textLabel?.text = "用户设置"
        } else if indexPath.row == 3 {
            cell?.textLabel?.text = "商家设置"
        }
        return cell!
    }
    // 设置每节标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "基本设置"
    }
    // 设置用户选中一行行为
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        if indexPath.row == 0 { //设置分类组
            let vc = sb.instantiateViewController(withIdentifier: "VCSetCC")
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 { // 设置区域
            let vc = sb.instantiateViewController(withIdentifier: "VCSetArea")
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 2 {  // 设置用户
            let vc = sb.instantiateViewController(withIdentifier: "VCSetOwner")
            self.navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 3 { // 商家设置
            let vc = sb.instantiateViewController(withIdentifier: "VCSetMarchant")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
