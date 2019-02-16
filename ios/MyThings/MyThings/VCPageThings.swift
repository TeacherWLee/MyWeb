//
//  VCPageThings.swift
//  MyThings
//
//  Created by 李巍 on 2017/12/14.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

class VCPageThings: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private var m_arrThings: [Thing]!
    private var m_nCurrentIndex = 0
    private var m_popMenu: SwiftPopMenu!                  // 弹出菜单
    private var m_inputThing: Thing!
    private var m_vcCurrentEditThing: VCEditThing!
    
    init(things: [Thing], currentIndex: Int) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        m_arrThings = things
        m_nCurrentIndex = currentIndex
        m_inputThing = m_arrThings[m_nCurrentIndex]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        // ---- navigation controller ----
        self.navigationItem.title = m_arrThings[m_nCurrentIndex].name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "pop_menu"), style: .plain, target: self, action: #selector(self.showMenu))
        
        // ---- Deal Data ----
        delegate = self
        dataSource = self
        
        m_vcCurrentEditThing = VCEditThing(thing: m_arrThings[m_nCurrentIndex], editType: .EDIT_TYPE_VIEW)
        setViewControllers([m_vcCurrentEditThing], direction: .forward, animated: true, completion: nil)
        
    }
    
    // ------ Pop Menu Actions ------
    @objc func showMenu() {
        m_popMenu = SwiftPopMenu(frame:  CGRect(x: self.view.bounds.size.width - 120, y: 51, width: 115, height: 462), arrowMargin: 12)
        
        m_popMenu.popData = [(icon:"thing_detail",title:"物品详情"),
                             (icon:"thing_edit",title:"编辑物品"),
                             (icon:"thing_increase",title:"数量增加"),
                             (icon:"thing_decrease",title:"数量减少"),
                             (icon:"thing_category",title:"设为正常"),
                             (icon:"thing_category",title:"设为保留"),
                             (icon:"thing_category",title:"设为备用"),
                             (icon:"thing_lost",title:"设为丢失"),
                             (icon:"thing_delete",title:"删除物品")]
        //点击菜单
        m_popMenu.didSelectMenuBlock = { [weak self](index:Int)->Void in
            self?.m_popMenu.dismiss()
            
            if index == 0 { // 物品详情
                let vc = VCDetailThing()
                vc.m_thing = self?.m_inputThing
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            if index == 1 { // 编辑物品
                let vc = VCEditThing(thing: (self?.m_inputThing)!, editType: .EDIT_TYPE_EDIT)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            if index == 2 { // 数量增加
                let rst = DP.dp.increaseThings(things: (self?.m_inputThing)!)
                if rst != 0 {
                    tipLabel(view: self!.view, strTip: "增加物品数量 \(String(describing: self?.m_inputThing.name)) 成功")
                    self?.m_inputThing.count += 1
                    //self?.m_vcCurrentEditThing.setThingCount(cnt: self!.m_inputThing.count)
                    let vcSuperListThing = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                    vcSuperListThing.refresh(p: nil)
                } else {
                    tipLabel(view: self!.view, strTip: "增加物品数量 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                }
            }
            if index == 3 { // 数量减少
                if (self?.m_inputThing.count)! < 1 {
                    return
                } else {
                    let rst = DP.dp.decreaseThings(things: (self?.m_inputThing)!)
                    if rst != 0 {
                        tipLabel(view: self!.view, strTip: "减少物品数量 \(String(describing: self?.m_inputThing.name)) 成功")
                        self?.m_inputThing.count -= 1
                        //self?.m_vcCurrentEditThing.setThingCount(cnt: self!.m_inputThing.count)
                        let vcSuperListThing = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                        vcSuperListThing.refresh(p: nil)
                    } else {
                        tipLabel(view: self!.view, strTip: "减少物品数量 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                    }
                }
            }
            if index == 4 { // 设为正常
                let rst = DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_NORMAL)
                if rst != 0 {
                    tipLabel(view: self!.view, strTip: "设置正常状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    let vcSuper = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                    vcSuper.refresh(p: nil)
                    let vcSuperSuper = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2]
                    if vcSuperSuper is VCMainCategory {
                        (vcSuperSuper as! VCMainCategory).refresh(p: nil)
                    }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置正常状态 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                }
            }
            if index == 5 { // 设为保留
                let rst = DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_STORAGE)
                if rst != 0 {
                    tipLabel(view: self!.view, strTip: "设置保留状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    let vc = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                    vc.refresh(p: nil)
                    let vcSuperSuper = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2]
                    if vcSuperSuper is VCMainCategory {
                        (vcSuperSuper as! VCMainCategory).refresh(p: nil)
                    }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置保留状态 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                }
            }
            if index == 6 { // 设为备用
                let rst = DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_RESERVE)
                if rst != 0 {
                    tipLabel(view: self!.view, strTip: "设置备用状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    let vc = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                    vc.refresh(p: nil)
                    let vcSuperSuper = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2]
                    if vcSuperSuper is VCMainCategory {
                        (vcSuperSuper as! VCMainCategory).refresh(p: nil)
                    }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置备用状态 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                }
            }
            if index == 7 { // 设为丢失
                let rst = DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_LOST)
                if rst != 0 {
                    tipLabel(view: self!.view, strTip: "设置丢失状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    let vc = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                    vc.refresh(p: nil)
                    let vcSuperSuper = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2]
                    if vcSuperSuper is VCMainCategory {
                        (vcSuperSuper as! VCMainCategory).refresh(p: nil)
                    }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置丢失状态 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                }
            }
            if index == 8 { // 删除物品
                let rst = DP.dp.setThingState(thing: self!.m_inputThing, toState: .STATE_DELETE)
                if rst != 0 {
                    tipLabel(view: self!.view, strTip: "设置删除状态 \(String(describing: self?.m_inputThing.name)) 成功")
                    let vc = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2] as! VCListThings
                    vc.refresh(p: nil)
                    let vcSuperSuper = self!.navigationController?.viewControllers[(self!.navigationController?.viewControllers.count)! - 2]
                    if vcSuperSuper is VCMainCategory {
                        (vcSuperSuper as! VCMainCategory).refresh(p: nil)
                    }
                    self!.navigationController?.popViewController(animated: true)
                } else {
                    tipLabel(view: self!.view, strTip: "设置删除状态 \(String(describing: self?.m_inputThing.name)) 失败，返回值 \(rst)")
                }
            }
        }
        m_popMenu.show()
    }
    
    // MARK: PageViewController Datasource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if m_nCurrentIndex == 0 {
            return nil
        }
        
        m_nCurrentIndex -= 1
        self.navigationItem.title = m_arrThings[m_nCurrentIndex].name
        m_vcCurrentEditThing = VCEditThing(thing: m_arrThings[m_nCurrentIndex], editType: .EDIT_TYPE_VIEW)
        return m_vcCurrentEditThing
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if m_nCurrentIndex == m_arrThings.count - 1 {
            return nil
        }
        
        m_nCurrentIndex += 1
        self.navigationItem.title = m_arrThings[m_nCurrentIndex].name
        m_vcCurrentEditThing = VCEditThing(thing: m_arrThings[m_nCurrentIndex], editType: .EDIT_TYPE_VIEW)
        return m_vcCurrentEditThing
    }
}
