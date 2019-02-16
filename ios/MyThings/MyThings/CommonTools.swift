//
//  CommonTools.swift
//  MyThings
//
//  Created by Li Wei on 2017/2/5.
//  Copyright © 2017年 LiWei. All rights reserved.
//

import Foundation
import UIKit

/*
 * \brief           显示提示信息
 * \param view      需要显示提示信息的视图
 * \param strTip    提示信息内容
 */
func tipLabel(view: UIView, strTip: String) {
  let label = UILabel(frame: CGRect(x: 0, y: NAV_HEIGHT, width: Int(view.frame.size.width), height: 30))
  label.backgroundColor = UIColor.white
  label.textColor = UIColor.lightGray
  label.textAlignment = .center
  label.text = strTip
  view.addSubview(label)
  label.alpha = 0
  
  UIView.animate(withDuration: 1.5, delay: 0, options: [], animations: {
    label.alpha = 1
  }) { (true) in
    label.alpha = 0
  }
}


func alertTip(vc:UIViewController, message: String) {
    let alertCtrl = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
    alertCtrl.addAction(cancelAction)
    vc.present(alertCtrl, animated: true, completion: nil)
}


func getStateName(state: Int) -> String {
    switch state {
    case DataState.STATE_NORMAL.rawValue:
        return "正常状态"
    case DataState.STATE_DELETE.rawValue:
        return "删除状态"
    case DataState.STATE_STORAGE.rawValue:
        return "保留状态"
    case DataState.STATE_RESERVE.rawValue:
        return "备用状态"
    case DataState.STATE_LOST.rawValue:
        return "丢失状态"
    case DataState.STATE_DESTROY.rawValue:
        return "彻底删除状态"
    case DataState.STATE_ALL.rawValue:
        return "全部状态"
    default:
        return ""
    }
}


func date2String(date: Date, dateFormat: String) -> String {
    let df = DateFormatter()
    df.locale = Locale.current
    df.dateFormat = dateFormat
    return df.string(from: date)
}
