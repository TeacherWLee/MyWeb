//
//  DataProcess.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import Foundation
import UIKit

// -------------------------------------------------------------------------------
// MARK: APP Configration
// ------ 高度与距离 ------
public let SAFE_AREA_MARGIN = 20                            // 距离屏幕边缘的安全距离
public let NAV_HEIGHT = 60                                  // 导航栏高度
public let DEFAULT_HEIGHT = 30                              // 默认标签高度
public let SEPARATE_HEIGHT = 8                              // 标签间的分隔符高度
public let TABLE_SECTION_H: CGFloat = 50.0                  // TableView 节标题高度
public let TABLE_CELL_H: CGFloat = 80.0                     // TableView 单元格高度
public let TABLE_ROW_H_LIST: CGFloat = 60.0                 // TableView 行高度（普通列表）
public let SCROLL_HEIGHT: CGFloat = 2000                    // 滚动视图高度
public let THING_LIST_TABLE_HEIGHT: CGFloat = 80            // 物品列表表视图项高度
//public let WIDTH_ID: Int = 35                               // "ID："字符串宽度
//public let WIDTH_2_CHS: Int = 55                            // 两个汉字字符串宽度
public let WIDTH_4_CHS: Int = 90                            // 四个汉字字符串宽度

// ------ 图片与动画 ------
public let DEFAULT_IMG_SIZE = 200                           // 图片尺寸
public let THING_IMG_SIZE = 300                             // 物品视图的图片尺寸
public let CAMERA_IMG_SIZE = 30                             // 启动摄像头图标尺寸
public let CORNER_RADIUS: CGFloat = 10.0                    // 图片圆角比例

// ------ 弹出输入法或选择器设置 ------
public let PVHEIGHT = 220                                   // pickerView高度
public var KEYBOARD_HEIGHT: CGFloat = 299                   // 默认键盘高度
public let TEXTFIELD_MOVE_TIME: Double = 0.3                // 输入法遮挡文本域后，移动时间动画时间

// ------ 数据同步设置 ------
public let SYNC_SERVER_PORT: UInt16 = 42421                 // 同步时，服务器监听端口号
public var SYNC_IP: String = "127.0.0.1"                    // 同步时，对方节点的IP地址
public let SYNC_CTMT_BYTE_CNT = 16                          // 一组createtime与modifytime转成Byte数组，数组长度
public let SYNC_MTU: Int = 1300                             // 同步时，最大传输单元字节数
public let SYNC_SEND_GROUP_MTU = 1296                       // 一个传输单元（分组）发送的CT和MS的字节数，16字节的倍数

// -------------------------------------------------------------------------------
// MARK: Enum
// ------ 编辑类型 ------
enum EditType {                         // 编辑类型
    case EDIT_TYPE_EDIT                 // 编辑状态
    case EDIT_TYPE_NEW                  // 新增状态
    case EDIT_TYPE_VIEW                 // 查看状态
}

// ------ 数据库各条目的状态值 ------
enum DataState: Int {
    case STATE_NORMAL = 0               // 正常状态
    case STATE_DELETE                   // 删除状态
    case STATE_STORAGE                  // 保留状态
    case STATE_RESERVE                  // 备用状态
    case STATE_LOST                     // 丢失状态
    case STATE_DESTROY                  // 彻底删除状态
    case STATE_ALL                      // 全部状态
}

// ------ 物品列表类型 ------
public enum ThingListType {
    case THINGLIST_DEFAULT                          // 默认的类型
    case THINGLIST_SPECIAL_CATEGORY                 // 某个特定分类的正常状态物品列表
    case THINGLIST_SPECIAL_POSITION                 // 某个特定位置的正常状态物品列表
    case THINGLIST_SPECIAL_CATEGORY_STORAGE         // 某个特定分类的保留物品列表
    case THINGLIST_SPECIAL_CATEGORY_DELETE          // 某个特定分类的删除物品列表
    case THINGLIST_STORAGE                          // 保留物品列表
    case THINGLIST_RESERVE                          // 备用物品列表
    case THINGLIST_ALL                              // 所有物品列表
    case THINGLIST_DELETE                           // 所有物品列表
    case THINGLIST_LOST                             // 丢失物品列表
    case THINGLIST_EXPEIR                           // 过期物品列表
}

// ------ 列表类型 ------
public enum ListType {
    case LIST_TYPE_NORMAL                           // 显示正常物品的分类
    case LIST_TYPE_STORAGE                          // 显示保留物品的分类
    case LIST_TYPE_DELETE                           // 显示删除物品的分类
}

// --------------------------------------------------------------------
// MARK: global data members
public var g_dKeyboardHeight: CGFloat = KEYBOARD_HEIGHT


// MARK: data structures
struct CategoryCollection {             // 物品类别组
    var id: Int
    var name: String
    var detail: String
    var img: String
    var oid: Int
    var state: Int
    var createtime: Date
    var modifytime: Date
}
struct Category {                       // 物品类别
    var id: Int
    var name:String
    var cc: Int
    var img: String
    var detail: String
    var maxcount: Int
    var oid: Int
    var state: Int
    var createtime: Date
    var modifytime: Date
}
struct Area {                           // 区域
    var id: Int
    var name: String
    var detail: String
    var img: String
    var oid: Int
    var state: Int
    var createtime: Date
    var modifytime: Date
}
struct Position {                       // 地点位置
    var id: Int
    var name:String
    var area: Int
    var img: String
    var detail: String
    var oid: Int
    var state: Int
    var createtime: Date
    var modifytime: Date
}
struct Owner {                          // 用户
    var id: Int
    var name:String
    var img: String
    var detail: String
    var u_name: String
    var password: String
    var oid: Int
    var state: Int
    var createtime: Date
    var modifytime: Date
}
struct Marchant {                       // 商家
    var id: Int
    var name:String
    var img: String
    var detail: String
    var oid: Int
    var state: Int
    var createtime: Date
    var modifytime: Date
}
struct Thing {                          // 物品
    var id: Int
    var name: String
    var category: Int
    var position: Int
    var owner: Int
    var count: Int
    var maxcount: Int
    var date: Date
    var expeir: Date
    var price: Double
    var img: String
    var marchant: Int
    var type: String
    var detail: String
    var state: Int
    var createtime: Date
    var modifytime: Date
}



// --------------------------------------------------------------------
// MARK: protocols
public protocol RefreshViewDelegate {
    func refresh(p: Any?)
}



// --------------------------------------------------------------------
// MARK: DataProcess
final class DP {                   // 数据处理类
    // MARK: data members
    public static let dp = DP()      // 全局数据处理静态对象
    private var db: SQLiteDB!                 // SQLiteDB数据库封装对象
    private let m_fileManager = FileManager.default       // 文件管理对象
    
    init() {                                  // 构造函数
        db = SQLiteDB.shared
        _ = db.open()
    }
    
    // MARK: 处理数据库文件
    public func deleteDB() {
        // 获取Document目录路径
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let rst = fileManager.fileExists(atPath: (dir?.path)!)
        if !rst {       // 目录不存在，返回空
            return
        }
        
        let dbPath = dir?.appendingPathComponent("data.db")
        
        print("delete \((dbPath?.path)!)")
        
        do {
            try fileManager.removeItem(atPath: (dbPath?.path)!)
            print ("delete database \(String(describing: dbPath)) success.")
        } catch {
            print ("delete database \(String(describing: dbPath)) failure.")
        }
        
    }
    
    
    // -------------------------------------------------------------------------------
    // MARK: 处理类别组 Categoty Collection
    private func parseCC(data:[[String:Any]]) -> [CategoryCollection] {  // 解析查询结果
        var rst:[CategoryCollection] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let detail = item["detail"] as! String
            let img = item["img"] as! String; let oid = item["oid"] as! Int; let state = item["state"] as! Int
            let createtime = item["createtime"] as! Date; let modifytime = item["modifytime"] as! Date
            let d = CategoryCollection(id: id, name: name, detail: detail, img: img, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(d)
        }
        return rst
    }
    
    public func addCC(name:String, imgPath:String, detail:String, oid: Int) -> Int {    // 添加类别组
        let now = Date()
        let sql = "INSERT INTO category_collection(name, img, detail, oid, state, createtime, modifytime) VALUES('\(name)', '\(imgPath)', '\(detail)', '\(oid)', '\(DataState.STATE_NORMAL.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }
    
    public func updateCC(cc: CategoryCollection) -> Int {       // 更新分类组
        var sql = "UPDATE category_collection SET name = '\(cc.name)', img = '\(cc.img)', detail = '\(cc.detail)', oid = '\(cc.oid)', state = '\(cc.state)', modifytime = '\(cc.modifytime)' WHERE createtime = '\(cc.createtime)'"
        if getCC(createtime: cc.createtime) == nil {sql = "INSERT INTO category_collection(name, img, detail, oid, state, createtime, modifytime) VALUES('\(cc.name)', '\(cc.img)', '\(cc.detail)', '\(cc.oid)', '\(cc.state)', '\(cc.createtime)', '\(cc.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    public func getCCs(state: DataState) -> [CategoryCollection] {
        var sql = "SELECT * FROM category_collection WHERE state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM category_collection ORDER BY oid"}
        return parseCC(data: db.query(sql: sql))
    }
    
    public func getCC(id:Int) -> CategoryCollection? {              // 获取分类组
        let sql = "SELECT * FROM category_collection WHERE id = \(id)"
        return parseCC(data: db.query(sql: sql)).first
    }
    
    public func getCC(createtime: Date) -> CategoryCollection? {
        let sql = "SELECT * FROM category_collection WHERE createtime = '\(createtime)'"
        return parseCC(data: db.query(sql: sql)).first
    }
    
    func deleteCC(cc: CategoryCollection) -> Int {                     // 删除分类组
        let sql = "UPDATE category_collection SET state='\(DataState.STATE_DELETE.rawValue)', modifytime='\(Date())' WHERE id='\(cc.id)'"
        return db.execute(sql: sql)
    }

    
    // MARK: 处理物品分类 Category
    private func parseCategory(data:[[String:Any]]) -> [Category] {  // 解析查询结果
        var rst:[Category] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let cc = item["cc"] as! Int
            let img = item["img"] as! String; let detail = item["detail"] as! String; let maxcount = item["maxcount"] as! Int
            let oid = item["oid"] as! Int; let state = item["state"] as! Int; let createtime = item["createtime"] as! Date
            let modifytime = item["modifytime"] as! Date
            let d = Category(id: id, name: name, cc: cc, img: img, detail: detail, maxcount: maxcount, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(d)
        }
        return rst
    }
    
    public func addCategory(name:String, cc:CategoryCollection, img:String, detail:String, maxcount:Int, oid:Int) -> Int { // 添加分类
        let now = Date()
        let sql = "INSERT INTO category(name, cc, img, detail, maxcount, oid, state, createtime, modifytime) VALUES('\(name)', '\(cc.id)', '\(img)', '\(detail)', '\(maxcount)', '\(oid)', '\(DataState.STATE_NORMAL.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }
    
    public func updateCategory(category: Category) -> Int {       // 更新分类
        var sql = "UPDATE category SET name='\(category.name)', cc='\(category.cc)', img='\(category.img)', detail='\(category.detail)', maxcount='\(category.maxcount)', oid='\(category.oid)', state='\(category.state)', modifytime='\(category.modifytime)' WHERE createtime='\(category.createtime)'"
        if getCategory(createtime: category.createtime) == nil {sql = "INSERT INTO category(name, cc, img, detail, maxcount, oid, state, createtime, modifytime) VALUES('\(category.name)', '\(category.cc)', '\(category.img)', '\(category.detail)', '\(category.maxcount)', '\(category.oid)', '\(category.state)', '\(category.createtime)', '\(category.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    public func getCategorys(state: DataState) -> [Category] {
        var sql = "SELECT * FROM category WHERE state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM category ORDER BY oid"}
        return parseCategory(data: db.query(sql: sql))
    }
    
    public func getCategorys(inCC: CategoryCollection, state: DataState) -> [Category] {            //< 获取指定类别组CC的所有正常状态的类别Categories
        var sql = "SELECT * FROM category WHERE cc='\(inCC.id)' AND state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM category WHERE cc='\(inCC.id)' ORDER BY oid"}
        return parseCategory(data: db.query(sql: sql))
    }
    
    public func getCategory(id: Int) -> Category? {    // 获取分类实例
        let sql = "SELECT * FROM category WHERE id = \(id)"
        return parseCategory(data: db.query(sql: sql)).first
    }
    
    public func getCategory(createtime: Date) -> Category? {
        let sql = "SELECT * FROM category WHERE createtime = '\(createtime)'"
        return parseCategory(data: db.query(sql: sql)).first
    }
    
    public func getCategoryCnt(inCC: CategoryCollection, state: DataState) -> Int {   //< 获取指定类别组CC中的所有正常状态类别Category数量。
        var sql = "SELECT COUNT(*) AS number FROM category WHERE cc='\(inCC.id)' AND state='\(state.rawValue)'"
        if state == .STATE_ALL {sql = "SELECT COUNT(*) AS number FROM category WHERE cc='\(inCC.id)'"}
        return db.query(sql: sql).first!["number"] as! Int
    }
    
    func deleteCategory(category: Category) -> Int {       // 删除分类
        let sql = "UPDATE category SET state='\(DataState.STATE_DELETE.rawValue)', modifytime='\(Date())' WHERE id='\(category.id)'"
        return db.execute(sql: sql)
    }
    
    
    // MARK: 处理区域 Area
    private func parseArea(data:[[String:Any]]) -> [Area] {  // 解析查询结果
        var rst:[Area] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let detail = item["detail"] as! String
            let imgPath = item["img"] as! String; let oid = item["oid"] as! Int; let state = item["state"] as! Int
            let createtime = item["createtime"] as! Date; let modifytime = item["modifytime"] as! Date
            let d = Area(id: id, name: name, detail: detail, img: imgPath, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(d)
        }
        return rst
    }
    
    public func addArea(name:String, img:String, detail:String, oid: Int) -> Int {  // 添加区域
        let now = Date()
        let sql = "INSERT INTO area(name, img, detail, oid, state, createtime, modifytime) VALUES('\(name)', '\(img)', '\(detail)', '\(oid)', '\(DataState.STATE_NORMAL.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }
    
    public func updateArea(area: Area) -> Int {       // 更新区域
        var sql = "UPDATE area SET name = '\(area.name)', img = '\(area.img)', detail = '\(area.detail)', oid = '\(area.oid)', state = '\(area.state)', modifytime = '\(area.createtime)' WHERE createtime = '\(area.createtime)'"
        if getArea(createtime: area.createtime) == nil {sql = "INSERT INTO area(name, img, detail, oid, state, createtime, modifytime) VALUES('\(area.name)', '\(area.img)', '\(area.detail)', '\(area.oid)', '\(area.state)', '\(area.createtime)', '\(area.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    func getAreas(state: DataState) -> [Area] {
        var sql = "SELECT * FROM area WHERE state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM area ORDER BY oid"}
        return parseArea(data: db.query(sql: sql))
    }
    
    func getArea(id:Int) -> Area? {              // 获取区域
        let sql = "SELECT * FROM area WHERE id = \(id)"
        return parseArea(data: db.query(sql: sql)).first
    }
    
    func getArea(createtime: Date) -> Area? {
        let sql = "SELECT * FROM area WHERE createtime = '\(createtime)'"
        return parseArea(data: db.query(sql: sql)).first
    }

    func deleteArea(area: Area) -> Int {   // 删除区域
        let sql = "UPDATE area SET state='\(DataState.STATE_DELETE.rawValue)', modifytime='\(Date())' WHERE id='\(area.id)'"
        return db.execute(sql: sql)
    }
    
    
    // MARK: 处理位置 Position
    private func parsePosition(data:[[String:Any]]) -> [Position] {  // 解析查询结果
        var rst:[Position] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let detail = item["detail"] as! String
            let img = item["img"] as! String; let oid = item["oid"] as! Int; let area = item["area"] as! Int
            let state = item["state"] as! Int; let createtime = item["createtime"] as! Date; let modifytime = item["modifytime"] as! Date
            let d = Position(id: id, name: name, area: area, img: img, detail: detail, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(d)
        }
        return rst
    }
    
    public func addPosition(name:String, area:Area, img:String, detail:String, oid:Int) -> Int {   // 添加位置
        let now = Date()
        let sql = "INSERT INTO position(name, area, img, detail, oid, state, createtime, modifytime) VALUES('\(name)', '\(area.id)', '\(img)', '\(detail)', '\(oid)', '\(DataState.STATE_NORMAL.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }

    public func updatePosition(position: Position) -> Int {       // 更新位置
        var sql = "UPDATE position SET name = '\(position.name)', area = '\(position.area)', img = '\(position.img)', detail = '\(position.detail)', oid = '\(position.oid)', state = '\(position.state)', modifytime = '\(position.createtime)' WHERE createtime = '\(position.createtime)'"
        if getPosition(createtime: position.createtime) == nil {sql = "INSERT INTO position(name, area, img, detail, oid, state, createtime, modifytime) VALUES('\(position.name)', '\(position.area)', '\(position.img)', '\(position.detail)', '\(position.oid)', '\(position.state)', '\(position.createtime)', '\(position.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    public func getPositions(state: DataState) -> [Position] {
        var sql = "SELECT * FROM position WHERE state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM position ORDER BY oid"}
        return parsePosition(data: db.query(sql: sql))
    }
    
    public func getPositionCnt(inArea: Area, state: DataState) -> Int {   //< 获取指定区域Area中的所有正常状态位置Position数量。
        var sql = "SELECT COUNT(*) AS number FROM position WHERE area='\(inArea.id)' and state='\(state.rawValue)'"
        if state == .STATE_ALL {sql = "SELECT COUNT(*) AS number FROM position WHERE area='\(inArea.id)'"}
        return db.query(sql: sql).first!["number"] as! Int
    }
    
    func getPosition(id: Int) -> Position? {    // 获取位置实例
        let sql = "SELECT * FROM position WHERE id = \(id)"
        return parsePosition(data: db.query(sql: sql)).first
    }
    
    func getPosition(createtime: Date) -> Position? {
        let sql = "SELECT * FROM position WHERE createtime = '\(createtime)'"
        return parsePosition(data: db.query(sql: sql)).first
    }
    
    func getPositions(inArea: Area, state: DataState) -> [Position] {
        var sql = "SELECT * FROM position WHERE area='\(inArea.id)' AND state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM position WHERE area='\(inArea.id)' ORDER BY oid"}
        return parsePosition(data: db.query(sql: sql))
    }
    
    func deletePosition(position: Position) -> Int {   // 删除位置
        let sql = "UPDATE position SET state='\(DataState.STATE_DELETE.rawValue)', modifytime='\(Date())' WHERE id='\(position.id)'"
        return db.execute(sql: sql)
    }
    
    
    // MARK: 处理用户 Owner
    private func parseOwner(data:[[String:Any]]) -> [Owner] {  // 解析查询结果
        var rst:[Owner] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let detail = item["detail"] as! String
            let imgPath = item["img"] as! String; let u_name = item["u_name"] as! String; let password = item["password"] as! String
            let oid = item["oid"] as! Int; let state = item["state"] as! Int
            let createtime = item["createtime"] as! Date; let modifytime = item["modifytime"] as! Date
            let d = Owner(id: id, name: name, img: imgPath, detail: detail, u_name: u_name, password: password, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(d)
        }
        return rst
    }
    
    public func addOwner(name:String, img:String, detail:String, u_name:String, password:String, oid: Int) -> Int {  // 添加用户
        let now = Date()
        let sql = "INSERT INTO owner(name, img, detail, u_name, password, oid, state, createtime, modifytime) VALUES('\(name)', '\(img)', '\(detail)', '\(u_name)', '\(password)', '\(oid)', '\(DataState.STATE_NORMAL.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }
    
    public func updateOwner(owner: Owner) -> Int {       // 更新用户
        var sql = "UPDATE owner SET name = '\(owner.name)', img = '\(owner.img)', detail = '\(owner.detail)', u_name = '\(owner.u_name)', password = '\(owner.password)', oid = '\(owner.oid)', state = '\(owner.state)', modifytime = '\(owner.createtime)' WHERE createtime = '\(owner.createtime)'"
        if getOwner(createtime: owner.createtime) == nil {sql = "INSERT INTO owner(name, img, detail, u_name, password, oid, state, createtime, modifytime) VALUES('\(owner.name)', '\(owner.img)', '\(owner.detail)', '\(owner.u_name)', '\(owner.password)', '\(owner.oid)', '\(owner.state)', '\(owner.createtime)', '\(owner.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    func getOwners(state: DataState) -> [Owner] {
        var sql = "SELECT * FROM owner WHERE state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM owner ORDER BY oid"}
        return parseOwner(data: db.query(sql: sql))
    }
    
    func getOwner(id: Int) -> Owner? {   // 获取用户实例
        let sql = "SELECT * FROM owner WHERE id = \(id)"
        return parseOwner(data: db.query(sql: sql)).first
    }
    
    func getOwner(createtime: Date) -> Owner? {
        let sql = "SELECT * FROM owner WHERE createtime = '\(createtime)'"
        return parseOwner(data: db.query(sql: sql)).first
    }
    
    func deleteOwner(owner:Owner) -> Int {    // 删除用户
        let sql = "UPDATE owner SET state='\(DataState.STATE_DELETE.rawValue)', modifytime='\(Date())' WHERE id='\(owner.id)'"
        return db.execute(sql: sql)
    }
    
    
    // MARK: 处理商家 Marchant
    private func parseMarchant(data:[[String:Any]]) -> [Marchant] {  // 解析查询结果
        var rst:[Marchant] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let detail = item["detail"] as! String
            let imgPath = item["img"] as! String; let oid = item["oid"] as! Int; let state = item["state"] as! Int
            let createtime = item["createtime"] as! Date; let modifytime = item["modifytime"] as! Date
            let d = Marchant(id: id, name: name, img: imgPath, detail: detail, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(d)
        }
        return rst
    }
    
    public func addMarchant(name:String, img:String, detail:String, oid: Int) -> Int {  // 添加商家
        let now = Date()
        let sql = "INSERT INTO marchant(name, img, detail, oid, state, createtime, modifytime) VALUES('\(name)', '\(img)', '\(detail)', '\(oid)', '\(DataState.STATE_NORMAL.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }
    
    public func updateMarchant(marchant: Marchant) -> Int {       // 更新商家
        var sql = "UPDATE marchant SET name = '\(marchant.name)', img = '\(marchant.img)', detail = '\(marchant.detail)', oid = '\(marchant.oid)', state = '\(marchant.state)', modifytime = '\(marchant.modifytime)' WHERE createtime = '\(marchant.createtime)'"
        let item = getMarchant(createtime: marchant.createtime)
        if item == nil {sql = "INSERT INTO marchant(name, img, detail, oid, state, createtime, modifytime) VALUES('\(marchant.name)', '\(marchant.img)', '\(marchant.detail)', '\(marchant.oid)', '\(marchant.state)', '\(marchant.createtime)', '\(marchant.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    func getMarchants(state: DataState) -> [Marchant] {
        var sql = "SELECT * FROM marchant WHERE state='\(state.rawValue)' ORDER BY oid"
        if state == .STATE_ALL {sql = "SELECT * FROM marchant ORDER BY oid"}
        return parseMarchant(data: db.query(sql: sql))
    }
    
    func getMarchant(id: Int) -> Marchant? {    // 获取商家
        let sql = "SELECT * FROM marchant WHERE id = \(id)"
        return parseMarchant(data: db.query(sql: sql)).first
    }
    
    func getMarchant(createtime: Date) -> Marchant? {
        let sql = "SELECT * FROM marchant WHERE createtime = '\(createtime)'"
        return parseMarchant(data: db.query(sql: sql)).first
    }
    
    func deleteMarchant(marchant:Marchant) -> Int {    // 删除商家
        let sql = "UPDATE marchant SET state='\(DataState.STATE_DELETE.rawValue)', modifytime='\(Date())' WHERE id='\(marchant.id)'"
        return db.execute(sql: sql)
    }
    
    
    //MARK: 处理物品 Things
    private func parseThing(data:[[String:Any]]) -> [Thing] {       // 解析事物查询结果
        var rst:[Thing] = []
        for item in data {
            let id = item["id"] as! Int; let name = item["name"] as! String; let categoty = item["category"] as! Int
            let position = item["position"] as! Int; let owner = item["owner"] as! Int; let count = item["count"] as! Int
            let maxcount = item["maxcount"] as! Int; let date = item["date"] as! Date; let expeir = item["expeir"] as! Date
            let price = item["price"] as! Double; let img = item["img"] as! String; let marchant = item["marchant"] as! Int
            let type = item["type"] as! String; let detail = item["detail"] as! String; let state = item["state"] as! Int
            let createtime = item["createtime"] as! Date; let modifytime = item["modifytime"] as! Date
            let thing = Thing(id: id, name: name, category: categoty, position: position, owner: owner, count: count, maxcount: maxcount, date: date, expeir: expeir, price: price, img: img, marchant: marchant, type: type, detail: detail, state: state, createtime: createtime, modifytime: modifytime)
            rst.append(thing)
        }
        return rst
    }
    
    public func addThing(name:String, category:Category, position:Position, owner:Owner, count:Int, maxcount:Int, date:Date, expeir:Date, price:Double, img:String, marchant:Marchant, type:String, detail:String, state: DataState) -> Int {  // 添加物品
        let now = Date()    // 获取当前时间戳
        let sql = "INSERT INTO things(name, category, position, owner, count, maxcount, date, expeir, price, img, marchant, type, detail, state, createtime, modifytime) VALUES('\(name)', '\(category.id)', '\(position.id)', '\(owner.id)', '\(count)', '\(maxcount)', '\(date)', '\(expeir)', '\(price)', '\(img)', '\(marchant.id)', '\(type)', '\(detail)', '\(state.rawValue)', '\(now)', '\(now)')"
        return db.execute(sql: sql)
    }
    
    public func updateThing(thing: Thing) -> Int {
        var sql = "UPDATE things SET name = '\(thing.name)', category = '\(thing.category)', position = '\(thing.position)', owner = '\(thing.owner)', count = '\(thing.count)', maxcount = '\(thing.maxcount)', date = '\(thing.date)', expeir = '\(thing.expeir)', price = '\(thing.price)', img = '\(thing.img)', marchant = '\(thing.marchant)', type = '\(thing.type)', detail = '\(thing.detail)', state = '\(thing.state)', modifytime = '\(thing.createtime)' WHERE createtime = '\(thing.createtime)'"
        if getThing(byCT: thing.createtime) == nil {sql = "INSERT INTO things(name, category, position, owner, count, maxcount, date, expeir, price, img, marchant, type, detail, state, createtime, modifytime) VALUES('\(thing.name)','\(thing.category)','\(thing.position)','\(thing.owner)','\(thing.count)','\(thing.maxcount)','\(thing.date)','\(thing.expeir)','\(thing.price)','\(thing.img)','\(thing.marchant)','\(thing.type)','\(thing.detail)','\(thing.state)','\(thing.createtime)','\(thing.modifytime)')"}
        return db.execute(sql: sql)
    }
    
    public func getThings(state: DataState) -> [Thing] {    // 获取所有物品
        var sql = "SELECT * FROM things WHERE state='\(state.rawValue)' ORDER BY modifytime DESC"
        if state == .STATE_ALL {sql = "SELECT * FROM things ORDER BY modifytime DESC"}
        return parseThing(data: db.query(sql: sql))
    }
    
    public func getThings(byCategory: Category, state: DataState) -> [Thing] {   // 获取物品，通过分类
        var sql = "SELECT * FROM things WHERE category='\(byCategory.id)' AND state='\(state.rawValue)' ORDER BY modifytime DESC"
        if state == .STATE_ALL {sql = "SELECT * FROM things WHERE category='\(byCategory.id)' ORDER BY modifytime DESC"}
        return parseThing(data: db.query(sql: sql))
    }
    
    public func getThings(byPosition: Position, state: DataState) -> [Thing] {   // 获取物品，通过分类
        var sql = "SELECT * FROM things WHERE position='\(byPosition.id)' AND state='\(state.rawValue)' ORDER BY modifytime DESC"
        if state == .STATE_ALL {sql = "SELECT * FROM things WHERE position='\(byPosition.id)' ORDER BY modifytime DESC"}
        return parseThing(data: db.query(sql: sql))
    }
    
    func getThing(byCT: Date) -> Thing? {
        let sql = "SELECT * FROM things WHERE createtime = '\(byCT)'"
        return parseThing(data: db.query(sql: sql)).first
    }
    
    public func getThing(createtime: Date) -> Thing? {
        let sql = "SELECT * FROM things WHERE createtime = '\(createtime)'"
        return parseThing(data: db.query(sql: sql)).first
    }
    
    public func getThingsCnt(inCategory: Category, state: DataState) -> Int {
        var sql = "SELECT COUNT(*) AS number FROM things WHERE category='\(inCategory.id)' AND state='\(state.rawValue)'"
        if state == .STATE_ALL {sql = "SELECT COUNT(*) AS number FROM things WHERE category='\(inCategory.id)'"}
        return db.query(sql: sql).first!["number"] as! Int
    }
    
    public func getThingsCnt(inPosition: Position, state: DataState) -> Int {
        var sql = "SELECT COUNT(*) AS number FROM things WHERE position='\(inPosition.id)' AND state='\(state.rawValue)'"
        if state == .STATE_ALL {sql = "SELECT COUNT(*) AS number FROM things WHERE position='\(inPosition.id)'"}
        return db.query(sql: sql).first!["number"] as! Int
    }
    
    public func getThingsCnt(inOwner: Owner, state: DataState) -> Int {
        var sql = "SELECT COUNT(*) AS number FROM things WHERE owner='\(inOwner.id)' AND state='\(state.rawValue)'"
        if state == .STATE_ALL {sql = "SELECT COUNT(*) AS number FROM things WHERE owner='\(inOwner.id)'"}
        return db.query(sql: sql).first!["number"] as! Int
    }
    
    public func getThingsCnt(inMarchant: Marchant, state: DataState) -> Int {
        var sql = "SELECT COUNT(*) AS number FROM things WHERE marchant='\(inMarchant.id)' AND state='\(state.rawValue)'"
        if state == .STATE_ALL {sql = "SELECT COUNT(*) AS number FROM things WHERE marchant='\(inMarchant.id)'"}
        return db.query(sql: sql).first!["number"] as! Int
    }
    
    func setThingState(thing: Thing, toState: DataState) -> Int {    // 设置为保留状态
        let sql = "UPDATE things SET state='\(toState.rawValue)', modifytime='\(Date())' WHERE id='\(thing.id)'"
        return db.execute(sql: sql)
    }
    
    func searchThings(keyword:String) -> [Thing] {
        let sql = "SELECT * FROM things WHERE name like '%\(keyword)%' OR detail like '%\(keyword)%' OR type like '%\(keyword)%' ORDER BY modifytime DESC"
        return parseThing(data: db.query(sql: sql))
    }
    
    func increaseThings(things:Thing) -> Int { // 增加物品数量
        let sql = "UPDATE things SET count='\(things.count+1)' WHERE id='\(things.id)'"
        return db.execute(sql: sql)
    }
    
    func decreaseThings(things:Thing) -> Int { // 减少物品数量
        let sql = "UPDATE things SET count='\(things.count-1)' WHERE id='\(things.id)'"
        return db.execute(sql: sql)
    }
    
    
    // ----------------------------------------------------------
    // MARK: 处理图片 Deal Images
    
    private func retrieveImgDirPath() -> URL? {
        guard let docsDir = m_fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("获取Documents文件夹失败")
            return nil
        }
        
        let imgDir = docsDir.appendingPathComponent("imgs", isDirectory: true)
        if !m_fileManager.fileExists(atPath: (imgDir.path)) {
            do {
                try m_fileManager.createDirectory(at: imgDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("*** Error: Create Img Directory Failure ***")
                return nil
            }
        }
        
        return imgDir
    }
    
    public func loadImage(img: String) -> UIImage? {
        guard let imgDir = retrieveImgDirPath() else {
            return nil
        }
        let imgPath = imgDir.appendingPathComponent(img)
        return UIImage(contentsOfFile: (imgPath.path))
    }
    
    public func saveImage(imgTitle: String, data: Data) -> Bool {      // 保存图片
        guard let imgDir = retrieveImgDirPath() else {
            return false
        }
        
        let imgPath = imgDir.appendingPathComponent(imgTitle)
        return m_fileManager.createFile(atPath: (imgPath.path), contents: data, attributes: nil)
    }
    
    public func saveImage(img:UIImage) -> String? {      // 保存图片，返回值是图片名称
        // ---- 压缩图片 ----
        let reSize = CGSize(width: 768, height: 768)
        UIGraphicsBeginImageContextWithOptions(reSize, false, 0.0)
        img.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: reSize))
        let imgResized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let d = UIImageJPEGRepresentation(imgResized!, 0.5)

        // ---- 存储文件 ----
        guard let imgDir = retrieveImgDirPath() else {
            return nil
        }
        
        let strImgTitle = date2String(date: Date(), dateFormat: "yyyyMMddHHmmss") + ".jpg"
        let imgPath = imgDir.appendingPathComponent(strImgTitle)

        if !m_fileManager.createFile(atPath: (imgPath.path), contents: d, attributes: nil) {
            print("*** Error: Save image failure ***")
            return nil
        }

        return strImgTitle
    }
    
    func deleteImage(img: String) -> Bool {      // 删除图片
        guard let imgDir = retrieveImgDirPath() else {
            return false
        }
        
        let imgPath = imgDir.appendingPathComponent(img)
        
        do {
            try m_fileManager.removeItem(atPath: (imgPath.path))
        } catch {
            print ("*** Error: Delete image \(img) failure ***")
            return false
        }
        
        return true
    }
    
    public func retrieveMissedOrUnusedImgs() -> (missedImgs: [String], unusedImgs: [String]) { // 返回所有本地缺失或者无用的图片文件名
        // ---- 获取数据库中所有的图片文件名称 ----
        var imgsInDB: [String] = []
        let tables = ["category_collection", "category", "area", "position", "owner", "marchant", "things"]
        for table in tables {
            let requeryRst = db.query(sql: "SELECT img FROM \(table)")
            for itemImg in requeryRst {
                imgsInDB.append(itemImg["img"] as! String)
            }
        }
        
        // ---- 获取本地img目录下所有图片文件 ----
        guard let imgDir = retrieveImgDirPath() else {
            return ([], [])
        }
        
        var imgsInDir: [String] = []
        do { try imgsInDir = m_fileManager.contentsOfDirectory(atPath: imgDir.path) } catch {
            
        }
        
        // ---- 比较差异 ----
        var arrMissedImgs: [String] = []
        var arrUnusedImgs: [String] = []
        
        for imgInDB in imgsInDB {
            if !imgsInDir.contains(imgInDB) {
                arrMissedImgs.append(imgInDB)
            }
        }
        
        for imgInDir in imgsInDir {
            if !imgsInDB.contains(imgInDir) {
                arrUnusedImgs.append(imgInDir)
            }
        }
        
        return (arrMissedImgs, arrUnusedImgs)
    }
    
    
    
    // ------------------------------------------------------------------------
    // MARK: Configration pList
    
    public func loadConfig() -> Bool {
        // 判断conf.plist是否存在，若存在读取数据，若不存在创建数据
        let docDir = m_fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let pListPath = docDir?.appendingPathComponent("conf.plist")
        
        var rst = m_fileManager.fileExists(atPath: (pListPath?.path)!)
        
        if !rst {
            rst = m_fileManager.createFile(atPath: (pListPath?.path)!, contents: nil, attributes: nil)
            if !rst {
                return false
            }
            
            // 写入默认值
            let dic = NSMutableDictionary()
            dic.setObject("127.0.0.1", forKey: "SyncIP" as NSCopying)
            dic.setObject(299, forKey: "KBHeight" as NSCopying)
            
            KEYBOARD_HEIGHT = 299
            SYNC_IP = "127.0.0.1"
            return true
        }
        
        guard let dicPList = NSMutableDictionary(contentsOfFile: (pListPath?.path)!) else {
            return false
        }
        
        SYNC_IP = dicPList["SyncIP" as NSCopying] as! String
        KEYBOARD_HEIGHT = dicPList["KBHeight" as NSCopying] as! CGFloat
        
        return true
    }
    
    
    // ------------------------------------------------------------------------
    // MARK: Execute a sql
    public func execute(sql: String) -> Int {
        return db.execute(sql: sql)
    }
}
