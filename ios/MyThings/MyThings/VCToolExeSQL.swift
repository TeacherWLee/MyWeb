//
//  VCToolExeSQL.swift
//  MyThings
//
//  Created by 李巍 on 2018/1/14.
//  Copyright © 2018年 李巍. All rights reserved.
//

import UIKit

class VCToolExeSQL: UIViewController {
    
    private var m_textViewSQL: UITextView!
    private var m_btnExec: UIButton!
    private var m_textViewRst: UITextView!
    
    private let TV_SQL_H = 200
    
    private var m_nLayoutY = NAV_HEIGHT + 15

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        // ---- navigation ----
        self.navigationItem.title = "执行SQL"
        
        // ---- layout ----
        let labelSQL = UITextView(frame: CGRect(x: SAFE_AREA_MARGIN, y: m_nLayoutY, width: Int(self.view.bounds.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        labelSQL.text = "输入SQL语句："
        self.view.addSubview(labelSQL)
        m_nLayoutY += DEFAULT_HEIGHT
        
        m_textViewSQL = UITextView(frame: CGRect(x: SAFE_AREA_MARGIN, y: m_nLayoutY, width: Int(self.view.bounds.width) - SAFE_AREA_MARGIN * 2, height: TV_SQL_H))
        m_textViewSQL.layer.borderColor = UIColor.lightGray.cgColor
        m_textViewSQL.layer.borderWidth = 1
        m_textViewSQL.layer.cornerRadius = 5
        m_textViewSQL.text = "DELETE FROM things WHERE id="
        self.view.addSubview(m_textViewSQL)
        m_nLayoutY = m_nLayoutY + TV_SQL_H + SEPARATE_HEIGHT
        
        m_btnExec = UIButton(frame: CGRect(x: SAFE_AREA_MARGIN, y: m_nLayoutY, width: Int(self.view.bounds.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        m_btnExec.setTitle("执行SQL语句", for: .normal)
        m_btnExec.setTitleColor(UIColor.darkGray, for: .normal)
        m_btnExec.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        m_btnExec.addTarget(self, action: #selector(btnExecAction), for: UIControlEvents.touchDown)
        self.view.addSubview(m_btnExec)
        m_nLayoutY = m_nLayoutY + DEFAULT_HEIGHT + SEPARATE_HEIGHT
        
        let labelRST = UITextView(frame: CGRect(x: SAFE_AREA_MARGIN, y: m_nLayoutY, width: Int(self.view.bounds.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        labelRST.text = "执行结果："
        self.view.addSubview(labelRST)
        m_nLayoutY += DEFAULT_HEIGHT
        
        m_textViewRst = UITextView(frame: CGRect(x: SAFE_AREA_MARGIN, y: m_nLayoutY, width: Int(self.view.bounds.width) - SAFE_AREA_MARGIN * 2, height: Int(self.view.bounds.height) - m_nLayoutY - 15))
        m_textViewRst.layer.borderColor = UIColor.lightGray.cgColor
        m_textViewRst.layer.borderWidth = 1
        m_textViewRst.layer.cornerRadius = 5
        m_textViewRst.isEditable = false
        self.view.addSubview(m_textViewRst)
    }
    
    @objc func btnExecAction() {
        guard let sql = m_textViewSQL.text else {
            addExeInfoText(text: "输入SQL语句无法读取")
            return
        }
        addExeInfoText(text: "SQL: \(sql)")
        
        let rst = DP.dp.execute(sql: sql)
        addExeInfoText(text: "Result: \(rst)")
    }
    
    func addExeInfoText(text: String) {
        m_textViewRst.text = m_textViewRst.text.appendingFormat("%@\n", text)
    }
}
