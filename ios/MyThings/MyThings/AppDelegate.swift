//
//  AppDelegate.swift
//  MyThings
//
//  Created by 李巍 on 2017/10/10.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
    
    var window: UIWindow?
    
    var vcMainCategory: VCMainCategory!
    var vcMainPosition: VCMainPosition!
    var vcMainSetting: VCMainSetting!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 创建并显示Window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        // 创建导航根视图控制器
        vcMainCategory = VCMainCategory(categoryType: .LIST_TYPE_NORMAL)
        vcMainPosition = VCMainPosition()
        vcMainSetting = VCMainSetting()
        
        // 创建导航控制器
        let navCategory = UINavigationController(rootViewController: vcMainCategory)
        let navPosition = UINavigationController(rootViewController: vcMainPosition)
        let navSetting = UINavigationController(rootViewController: vcMainSetting)
        
        // 设置分栏控制器按钮标题
        navCategory.tabBarItem.title = "分类"
        navPosition.tabBarItem.title = "位置"
        navSetting.tabBarItem.title = "设置"
        
        // 设置分栏控制器图片
        var imgCategory = UIImage(named: "Category_UnSelect")
        var imgSelectCategoty = UIImage(named: "Category_Select")
        imgCategory = imgCategory?.withRenderingMode(.alwaysOriginal)
        imgSelectCategoty = imgSelectCategoty?.withRenderingMode(.alwaysOriginal)
        navCategory.tabBarItem.image = imgCategory
        navCategory.tabBarItem.selectedImage = imgSelectCategoty
        
        var imgPosition = UIImage(named: "Position_UnSelect")
        var imgSelectPosition = UIImage(named: "Position_Select")
        imgPosition = imgPosition?.withRenderingMode(.alwaysOriginal)
        imgSelectPosition = imgSelectPosition?.withRenderingMode(.alwaysOriginal)
        navPosition.tabBarItem.image = imgPosition
        navPosition.tabBarItem.selectedImage = imgSelectPosition
        
        var imgSetting = UIImage(named: "Setting_UnSelect")
        var imgSelectSetting = UIImage(named: "Setting_Select")
        imgSetting = imgSetting?.withRenderingMode(.alwaysOriginal)
        imgSelectSetting = imgSelectSetting?.withRenderingMode(.alwaysOriginal)
        navSetting.tabBarItem.image = imgSetting
        navSetting.tabBarItem.selectedImage = imgSelectSetting
        
        // 创建分栏控制器
        let tabBarMain = UITabBarController()
        tabBarMain.viewControllers = [navCategory, navPosition, navSetting]
        
        tabBarMain.delegate = self
        
        // 将分栏控制器设为窗口根视图控制器
        window?.rootViewController = tabBarMain
        
        return true
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch tabBarController.selectedIndex {
        case 0: vcMainCategory.refresh(p: nil)
        case 1: vcMainPosition.refresh(p: nil)
        case 2: vcMainSetting.refresh()
        default:
            print("TabbarControllerError")
        }
//
//        if tabBarController.selectedIndex == 0 {
//            vcMainCategory.refresh(p: nil)
//        }
    }
}

