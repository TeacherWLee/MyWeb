//
//  DataProcess.swift
//  MyThings
//
//  Created by LiWei on 2016/12/27.
//  Copyright © 2016年 LiWei. All rights reserved.
//

import Foundation
import UIKit

// MARK: data structures
struct CategoryCollection {             // 物品类别组
    var id: Int
    var name: String
    var detail: String
    var img: String
}
struct Category {                       // 物品类别
    var id: Int
    var name:String
    var cc: Int
    var img: String
    var detail: String
    var maxcount: Int
    var oid: Int
}
struct Area {                           // 区域
    var id: Int
    var name: String
    var detail: String
    var img: String
}
struct Position {                       // 地点位置
    var id: Int
    var name:String
    var area: Int
    var img: String
    var detail: String
    var oid: Int
}
struct Owner {                          // 用户
    var id: Int
    var name:String
    var img: String
    var detail: String
    var u_name: String
    var password: String
}
struct Marchant {                       // 商家
    var id: Int
    var name:String
    var img: String
    var detail: String
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
    var timestamp: Date
}

class DataProcess {                     // 数据处理类
    // MARK: data members
    public static let dp = DataProcess()        // 全局数据处理静态对象
    var db: SQLiteDB!                   // SQLiteDB数据库封装对象
    
    init() {                            // 构造函数
        db = SQLiteDB.sharedInstance
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
            print ("delete database \(dbPath) success.")
        } catch {
            print ("delete database \(dbPath) failure.")
        }
        
    }
    
    // MARK: 处理类别组 Categoty Collection
    private func parseCC(data:[[String:Any]]) -> [CategoryCollection] {  // 解析查询结果
        var rst:[CategoryCollection] = []
        for item in data {
            let id: Int = item["id"] as! Int
            let name: String = item["name"] as! String
            let detail: String = item["detail"] as! String
            let imgPath: String = item["img"] as! String
            
            let d = CategoryCollection(id: id, name: name, detail: detail, img: imgPath)
            rst.append(d)
        }
        return rst
    }
    
    func getAllCC() -> [CategoryCollection] {                  // 获取全部分类组
        let sql = "select * from category_collection"
        let data = db.query(sql: sql)
        return parseCC(data: data)
    }
    
    func addCC(name:String, imgPath:String, detail:String) {    // 添加类别组
        let sql = "insert into category_collection(name,img,detail) values('\(name)','\(imgPath)','\(detail)')"
        print(db.execute(sql: sql))
    }

    func deleteCC(cc: CategoryCollection) {                     // 删除类别组
        deleteImage(img: cc.img)
        let sql = "delete from category_collection where id = '\(cc.id)'"
        print(db.execute(sql: sql))
    }

    func getCC(id:Int) -> CategoryCollection? {              // 获取分类组
        let sql = "select * from category_collection where id = \(id)"
        let data = db.query(sql: sql)
        let arrRst = parseCC(data: data)
        if arrRst.count > 0 {
            return arrRst[0]
        }
        return nil
    }
    
    func updateCC(cc: CategoryCollection) {       // 更新分类组
        let sql = "update category_collection set name='\(cc.name)',img='\(cc.img)',detail='\(cc.detail)' where id='\(cc.id)'"
        let rst = db.execute(sql: sql)
        print("update category with id:\(cc.id) and name:\(cc.name), execute result is: \(rst)")
    }
    
    // MARK: 处理物品分类 Category
    private func parseCategory(data:[[String:Any]]) -> [Category] {  // 解析查询结果
        var rst:[Category] = []
        for item in data {
            var id: Int = -1
            var name: String = ""
            var cc = -1
            var img: String = ""
            var detail: String = ""
            var maxcount = -1
            var oid = -1
            
            var data: Any?
            data = item["id"]
            if data != nil {
                id = data as! Int
            }
            data = item["name"]
            if data != nil {
                name = data as! String
            }
            data = item["cc"]
            if data != nil {
                cc = data as! Int
            }
            data = item["img"]
            if data != nil {
                img = data as! String
            }
            data = item["detail"]
            if data != nil {
                detail = data as! String
            }
            data = item["maxcount"]
            if data != nil {
                maxcount = data as! Int
            }
            data = item["oid"]
            if data != nil {
                oid = data as! Int
            }

            let d = Category(id: id, name: name, cc: cc, img: img, detail: detail, maxcount: maxcount, oid: oid)
            rst.append(d)
        }
        return rst
    }
    
    func getAllCategory() -> [Category] {       // 获取全部分类
        let sql = "select * from category order by oid asc"
        let data = db.query(sql: sql)
        return parseCategory(data: data)
    }
    
    func addCategory(name:String, cc:CategoryCollection, img:String, detail:String, maxcount:Int, oid:Int) { // 添加分类
        let sql = "insert into category(name,cc,img,detail,maxcount,oid) values('\(name)','\(cc.id)','\(img)','\(detail)','\(maxcount)','\(oid)')"
        print(db.execute(sql: sql))
    }
    
    func deleteCategory(category: Category) {   // 删除分类
        deleteImage(img: category.img)
        let sql = "delete from category where id = '\(category.id)'"
        print(db.execute(sql: sql))
    }
    
    func getCategory(id:Int) -> Category? {    // 获取分类实例
        let sql = "select * from category where id = \(id)"
        let data = db.query(sql: sql)
        let arrRst = parseCategory(data: data)
        if arrRst.count > 0 {
            return arrRst[0]
        }
        return nil
    }
    
    func getCategoryByCC(id:Int) -> [Category] {
        let sql = "select * from category where cc='\(id)' order by oid asc"
        let data = db.query(sql: sql)
        return parseCategory(data: data)
    }
    
    func updateCategory(category: Category) {       // 更新分类
        let sql = "update category set name='\(category.name)',cc='\(category.cc)',img='\(category.img)',detail='\(category.detail)',maxcount='\(category.maxcount)',oid='\(category.oid)' where id='\(category.id)'"
        let rst = db.execute(sql: sql)
        print("update category with id:\(category.id) and name:\(category.name), execute result is: \(rst)")
    }
    
    // MARK: 处理区域 Area
    private func parseArea(data:[[String:Any]]) -> [Area] {  // 解析查询结果
        var rst:[Area] = []
        for item in data {
            let id: Int = item["id"] as! Int
            let name: String = item["name"] as! String
            let detail: String = item["detail"] as! String
            let imgPath: String = item["img"] as! String
            let d = Area(id: id, name: name, detail: detail, img: imgPath)
            rst.append(d)
        }
        return rst
    }
    
    func getAllArea() -> [Area] {   // 获取全部区域
        let sql = "select * from area"
        let data = db.query(sql: sql)
        return parseArea(data: data)
    }
    
    func addArea(name:String, img:String, detail:String) {  // 添加区域
        let sql = "insert into area(name,img,detail) values('\(name)','\(img)','\(detail)')"
        print(db.execute(sql: sql))
    }

    func deleteArea(area: Area) {   // 删除区域
        deleteImage(img: area.img)
        let sql = "delete from area where id = '\(area.id)'"
        print(db.execute(sql: sql))
    }
    
    func getArea(id:Int) -> Area? {              // 获取区域
        let sql = "select * from area where id = \(id)"
        let data = db.query(sql: sql)
        let arrRst = parseArea(data: data)
        if arrRst.count > 0 {
            return arrRst[0]
        }
        return nil
    }
    
    func updateArea(area: Area) {       // 更新区域
        let sql = "update area set name='\(area.name)',img='\(area.img)',detail='\(area.detail)' where id='\(area.id)'"
        let rst = db.execute(sql: sql)
        print("update category with id:\(area.id) and name:\(area.name), execute result is: \(rst)")
    }
    
    // MARK: 处理位置 Position
    private func parsePosition(data:[[String:Any]]) -> [Position] {  // 解析查询结果
        var rst:[Position] = []
        for item in data {
            var id: Int = -1
            var name: String = ""
            var area: Int = -1
            var img: String = ""
            var detail: String = ""
            var oid: Int = -1
            
            var data: Any?
            data = item["id"]
            if data != nil {
                id = data as! Int
            }
            data = item["name"]
            if data != nil {
                name = data as! String
            }
            data = item["area"]
            if data != nil {
                area = data as! Int
            }
            data = item["img"]
            if data != nil {
                img = data as! String
            }
            data = item["detail"]
            if data != nil {
                detail = data as! String
            }
            data = item["oid"]
            if data != nil {
                oid = data as! Int
            }
            
            let d = Position(id: id, name: name, area: area, img: img, detail: detail, oid: oid)
            rst.append(d)
        }
        return rst
    }
    
    func getAllPosition() -> [Position] {   // 获取全部位置
        let sql = "select * from position order by oid asc"
        let data = db.query(sql: sql)
        return parsePosition(data: data)
    }
    
    func addPosition(name:String, area:Area, img:String, detail:String, oid:Int) {   // 添加位置
        let sql = "insert into position(name,area,img,detail,oid) values('\(name)','\(area.id)','\(img)','\(detail)','\(oid)')"
        print(db.execute(sql: sql))
    }
    
    func deletePosition(position: Position) {   // 删除位置
        deleteImage(img: position.img)
        let sql = "delete from position where id = '\(position.id)'"
        print(db.execute(sql: sql))
    }
    
    func getPosition(id:Int) -> Position? {    // 获取位置实例
        let sql = "select * from position where id = \(id)"
        let data = db.query(sql: sql)
        let arrRst = parsePosition(data: data)
        if arrRst.count > 0 {
            return arrRst[0]
        }
        return nil
    }
    
    func getPositionByArea(id:Int) -> [Position] {
        let sql = "select * from position where area='\(id)' order by oid asc"
        let data = db.query(sql: sql)
        return parsePosition(data: data)
    }
    
    func updatePosition(position: Position) {       // 更新位置
        let sql = "update position set name='\(position.name)',area='\(position.area)',img='\(position.img)',detail='\(position.detail)',oid='\(position.oid)' where id='\(position.id)'"
        let rst = db.execute(sql: sql)
        print("update position with id:\(position.id) and name:\(position.name), execute result is: \(rst)")
    }
    
    // MARK: 处理用户 Owner
    private func parseOwner(data:[[String:Any]]) -> [Owner] {  // 解析查询结果
        var rst:[Owner] = []
        for item in data {
            let id: Int = item["id"] as! Int
            let name: String = item["name"] as! String
            let detail: String = item["detail"] as! String
            let imgPath: String = item["img"] as! String
            let u_name: String = item["u_name"] as! String
            let password: String = item["password"] as! String
            let d = Owner(id: id, name: name, img: imgPath, detail: detail, u_name: u_name, password: password)
            rst.append(d)
        }
        return rst
    }
    
    func addOwner(name:String, img:String, detail:String, u_name:String, password:String) {  // 添加用户
        let sql = "insert into owner(name,img,detail,u_name,password) values('\(name)','\(img)','\(detail)','\(u_name)','\(password)')"
        print(db.execute(sql: sql))
    }
    
    func deleteOwner(owner:Owner) {    // 删除用户
        deleteImage(img: owner.img)
        let sql = "delete from owner where id = '\(owner.id)'"
        print(db.execute(sql: sql))
    }
    
    func getAllOwner() -> [Owner] {     // 获取全部用户
        let sql = "select * from owner"
        let data = db.query(sql: sql)
        return parseOwner(data: data)
    }
    
    func getOwner(id:Int) -> Owner? {   // 获取用户实例
        let sql = "select * from owner where id = \(id)"
        let data = db.query(sql: sql)
        let arrRst = parseOwner(data: data)
        if arrRst.count > 0 {
            return arrRst[0]
        }
        return nil
    }
    
    func updateOwner(owner: Owner) {       // 更新用户
        let sql = "update owner set name='\(owner.name)',img='\(owner.img)',detail='\(owner.detail)',u_name='\(owner.u_name)',password='\(owner.password)' where id='\(owner.id)'"
        let rst = db.execute(sql: sql)
        print("update category with id:\(owner.id) and name:\(owner.name), execute result is: \(rst)")
    }
    
    // MARK: 处理商家 Marchant
    private func parseMarchant(data:[[String:Any]]) -> [Marchant] {  // 解析查询结果
        var rst:[Marchant] = []
        for item in data {
            let id: Int = item["id"] as! Int
            let name: String = item["name"] as! String
            let detail: String = item["detail"] as! String
            let imgPath: String = item["img"] as! String
            let d = Marchant(id: id, name: name, img: imgPath, detail: detail)
            rst.append(d)
        }
        return rst
    }
    
    func getAllMarchant() -> [Marchant] {     // 获取全部商家
        let sql = "select * from marchant"
        let data = db.query(sql: sql)
        return parseMarchant(data: data)
    }
    
    func addMarchant(name:String, img:String, detail:String) {  // 添加商家
        let sql = "insert into marchant(name,img,detail) values('\(name)','\(img)','\(detail)')"
        print(db.execute(sql: sql))
    }
    
    func deleteMarchant(marchant:Marchant) {    // 删除商家
        deleteImage(img: marchant.img)
        let sql = "delete from marchant where id = '\(marchant.id)'"
        print(db.execute(sql: sql))
    }
    
    func getMarchant(id:Int) -> Marchant? {    // 获取商家
        let sql = "select * from marchant where id = \(id)"
        let data = db.query(sql: sql)
        let arrRst = parseMarchant(data: data)
        if arrRst.count > 0 {
            return arrRst[0]
        }
        return nil
    }
    
    func updateMarchant(marchant: Marchant) {       // 更新商家
        let sql = "update marchant set name='\(marchant.name)',img='\(marchant.img)',detail='\(marchant.detail)' where id='\(marchant.id)'"
        let rst = db.execute(sql: sql)
        print("update category with id:\(marchant.id) and name:\(marchant.name), execute result is: \(rst)")
    }

    //MARK: 处理物品 Things
    private func parseThing(data:[[String:Any]]) -> [Thing] {       // 解析事物查询结果
        var rst:[Thing] = []
        for item in data {
            let id: Int = item["id"] as! Int
            let name: String = item["name"] as! String
            let categoty = item["category"] as! Int
            let position = item["position"] as! Int
            let owner = item["owner"] as! Int
            let count = item["count"] as! Int
            let maxcount = item["maxcount"] as! Int
            let date = item["date"] as! Date
            let expeir = item["expeir"] as! Date
            let price = item["price"] as! Double
            let imgPath: String = item["img"] as! String
            let marchant = item["marchant"] as! Int
            let type = item["type"] as! String
            let detail: String = item["detail"] as! String
            let state = item["state"] as! Int
            let timestamp = item["timestamp"] as! Date
            
            let thing = Thing(id: id, name: name, category: categoty, position: position, owner: owner, count: count, maxcount: maxcount, date: date, expeir: expeir, price: price, img: imgPath, marchant: marchant, type: type, detail: detail, state: state, timestamp:timestamp)
            rst.append(thing)
        }
        return rst
    }
    
    func getAllThings() -> [Thing] {    // 获取所有物品
        let sql = "select * from things order by timestamp desc"
        let data = db.query(sql: sql)
        return parseThing(data: data)
    }
    
    func addThings(name:String, category:Category, position:Position, owner:Owner, count:Int, maxcount:Int, date:Date, expeir:Date, price:Double, img:String, marchant:Marchant, type:String, detail:String) {  // 添加物品
        let now = Date()    // 获取当前时间戳
        let sql = "insert into things(name,category,position,owner,count,maxcount,date,expeir,price,img,marchant,type,detail,state,timestamp) values('\(name)','\(category.id)','\(position.id)','\(owner.id)','\(count)','\(maxcount)','\(date)','\(expeir)','\(price)','\(img)','\(marchant.id)','\(type)','\(detail)','0','\(now)')"
        print(db.execute(sql: sql))
    }
    
    func updateThings(thing: Thing) {
        let sql = "update things set name='\(thing.name)',category='\(thing.category)',position='\(thing.position)',owner='\(thing.owner)',count='\(thing.count)',maxcount='\(thing.maxcount)',date='\(thing.date)',expeir='\(thing.expeir)',price='\(thing.price)',img='\(thing.img)',marchant='\(thing.marchant)',type='\(thing.type)',detail='\(thing.detail)',state='0',timestamp='\(thing.timestamp)' where id='\(thing.id)'"
        let rst = db.execute(sql: sql)
        print("update things with id:\(thing.id) and name:\(thing.name), execute result is: \(rst)")
    }
    
    func deleteThings(things:Thing) {   // 删除物品
        deleteImage(img: things.img)
        let sql = "delete from things where id = '\(things.id)'"
        print(db.execute(sql: sql))
    }
    
    func searchThings(keyword:String) -> [Thing] {
        let sql = "select * from things where name like '%\(keyword)%' OR detail like '%\(keyword)%' OR type like '%\(keyword)%' order by timestamp desc"
        let data = db.query(sql: sql)
        return parseThing(data: data)
    }
    
    func increaseThings(things:Thing) { // 增加物品数量
        let sql = "update things set count='\(things.count+1)' where id='\(things.id)'"
        print(db.execute(sql: sql))
    }
    
    func decreaseThings(things:Thing) { // 减少物品数量
        let sql = "update things set count='\(things.count-1)' where id='\(things.id)'"
        print(db.execute(sql: sql))
    }
    
    func getThingsByID(id: Int) -> Thing {   // 获取物品，通过物品ID
        let sql = "select * from things where id='\(id)' order by timestamp DESC"
        let data = db.query(sql: sql)
        return parseThing(data: data).first!
    }
    
    func getThingsByCategory(id:Int) -> [Thing] {   // 获取物品，通过分类
        let sql = "select * from things where category='\(id)' order by timestamp DESC"
        let data = db.query(sql: sql)
        return parseThing(data: data)
    }
    
    func getThingsByPosition(id:Int) -> [Thing] {   // 获取物品，通过分类
        let sql = "select * from things where position='\(id)' order by timestamp DESC"
        let data = db.query(sql: sql)
        return parseThing(data: data)
    }
    
    func getThingsByOwner(id:Int) -> [Thing] {   // 获取物品，通过用户
        let sql = "select * from things where owner='\(id)' order by timestamp DESC"
        let data = db.query(sql: sql)
        return parseThing(data: data)
    }
    
    func getThingsByMarchant(id:Int) -> [Thing] {   // 获取物品，通过商家
        let sql = "select * from things where marchant='\(id)' order by timestamp DESC"
        let data = db.query(sql: sql)
        return parseThing(data: data)
    }
    
    // MARK: 处理图片 Deal Images
    public func loadImage(img: String) -> UIImage? {
        // 获取Document目录路径
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imgDir = dir?.appendingPathComponent("imgs", isDirectory: true)
        
        let rst = fileManager.fileExists(atPath: (imgDir?.path)!)
        if !rst {       // 目录不存在，返回空
            return nil
        }
        
        let imgPath = imgDir?.appendingPathComponent(img)
        
        if imgPath?.path == nil {
            return nil
        } else {
            return UIImage(contentsOfFile: (imgPath?.path)!)
        }
    }
    
    public func saveImage(img:UIImage) -> String {      // 保存图片，返回值是图片名称
        // 压缩图片
        let reSize = CGSize(width: 768, height: 768)
        UIGraphicsBeginImageContextWithOptions(reSize, false, 0.0)
        img.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: reSize))
        let imgResized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let d = UIImageJPEGRepresentation(imgResized!, 0.5)
        
        // 存储文件
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imgDir = dir?.appendingPathComponent("imgs", isDirectory: true)
        
        var rst = fileManager.fileExists(atPath: (imgDir?.path)!)
        if !rst {
            do {
                try fileManager.createDirectory(at: imgDir!, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("error")
            }
        }
        
        let date = Date()
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "yyyyMMddHHmmss"
        let strDate = df.string(from: date)
        let imgPath = imgDir?.appendingPathComponent(strDate+".jpg")

        rst = fileManager.createFile(atPath: (imgPath?.path)!, contents: d, attributes: nil)
        if rst {
            return (strDate+".jpg")
        } else {
            return ""
        }
    }
    
    func deleteImage(img: String) {      // 删除图片
        // 获取Document目录路径
        let fileManager = FileManager.default
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imgDir = dir?.appendingPathComponent("imgs", isDirectory: true)
        
        let rst = fileManager.fileExists(atPath: (imgDir?.path)!)
        if !rst {       // 目录不存在，返回空
            return
        }
        
        let imgPath = imgDir?.appendingPathComponent(img)
        
        do {
            try fileManager.removeItem(atPath: (imgPath?.path)!)
        } catch {
            print ("delete image \(img) failure.")
        }
    }
}
