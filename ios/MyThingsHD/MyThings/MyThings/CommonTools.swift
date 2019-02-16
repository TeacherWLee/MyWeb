//
//  CommonTools.swift
//  MyThings
//
//  Created by Li Wei on 2017/2/5.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import Foundation
import UIKit

// MARK: format tableview cell
func formatCell(cell:UITableViewCell, thing:Thing) -> UITableViewCell {
    cell.textLabel?.textColor = UIColor.black
    cell.textLabel?.text = thing.name
    
    if thing.count == 0 {           // 数量为0时，改变颜色
        cell.textLabel?.textColor = UIColor.darkGray
    }
    
    if thing.maxcount > 0 {        // 超过最大数量限制
        if thing.count > thing.maxcount {
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel?.text = "\(thing.name)（\(thing.count)/\(thing.maxcount)）"
        }
    }
    
    if Date().compare(thing.expeir) == ComparisonResult.orderedDescending {        // 超过最大日期限制
        cell.textLabel?.textColor = UIColor.brown
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "yyyy-MM-dd"
        let strExpeir = df.string(from: thing.expeir)
        cell.textLabel?.text = "\(thing.name)（\(strExpeir)）"
    }
    
    let strCategoryName = DataProcess.dp.getCategory(id: thing.category)!.name
    let strPositionName = DataProcess.dp.getPosition(id: thing.position)!.name
    let strOwnerName = DataProcess.dp.getOwner(id: thing.owner)!.name
    let detailText = "\(strPositionName) | \(strCategoryName) | \(strOwnerName)"
    cell.detailTextLabel?.text = detailText
    
    var img = DataProcess.dp.loadImage(img: thing.img)
    if img == nil {
        img = UIImage(named: "default_thing")
    }
    
    cell.imageView?.image = img
    
    return cell
}

/*
 * \brief           显示提示信息
 * \param view      需要显示提示信息的视图
 * \param strTip    提示信息内容
 */
func tipLabel(view: UIView, strTip: String) {
    let label = UILabel(frame: CGRect(x: 0, y: 80, width: view.frame.size.width, height: 30))
    label.backgroundColor = UIColor.lightGray
    label.textAlignment = .center
    label.text = strTip
    view.addSubview(label)
    label.alpha = 0
    
    UIView.animate(withDuration: 2, delay: 0, options: [], animations: {
        label.alpha = 1
    }) { (true) in
        label.alpha = 0
    }
}
