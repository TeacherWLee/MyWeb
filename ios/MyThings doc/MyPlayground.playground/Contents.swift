//: Playground - noun: a place where people can play

import UIKit

class C1 {
    var n = 1
    
    var c2 = C2()
    
}

class C2 {
    public func changeValue(n: Int) {
        
    }
}




//func toByteArray<T>(_ value: T) -> [UInt8] {
//  var value = value
//  return withUnsafeBytes(of: &value) { Array($0) }
//}
//
//func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
//  return value.withUnsafeBytes {
//    $0.baseAddress!.load(as: T.self)
//  }
//}
//
//
//let d: Double = 3.14
//let bytes = toByteArray(d)
//print(bytes)
//let d2 = fromByteArray(bytes, Double.self)
//print(d2)


//var date1 = Date()
//print(date1)
//
//var date2 = date1 + 100
//print(date2)



//var bytesArray: [UInt8] = []
//for i in 0..<95 {
//  bytesArray.append(UInt8(i))
//}
//
//print(bytesArray.endIndex)
//print(bytesArray.count)
//
//var index = 0
//while index < bytesArray.count {
//  var endIndex = index + 10
//  if index + 10 > bytesArray.count {
//    endIndex = bytesArray.endIndex
//  }
//  print(endIndex)
//
//  let slice = bytesArray[index..<endIndex]
//  var bytesArray2: [UInt8] = []
//  bytesArray2.append(contentsOf: slice)
//  print(bytesArray2)
//  index += 10
//}
//
//
//enum flag: UInt8 {
//  case flag1 = 0
//  case flag2 = 1
//}
//
//var buffBytes_s: [UInt8] = []
//
//buffBytes_s.append(flag.flag1.rawValue)
//
//var data1 = "1234567"
//var buffData: [UInt8] = []
//buffData.append(contentsOf: Array(data1.utf8))
//var nUnitLen = buffData.count
//var arrUnitLen: [Int] = [nUnitLen]
//arrUnitLen.withUnsafeBytes {
//  buffBytes_s.append(contentsOf: $0)
//}
//
//buffBytes_s.append(contentsOf: Array(data1.utf8))
//
//let doubleValue: Double = 3.14
//var buffDouble: [Double] = []
//buffDouble.append(doubleValue)
//buffDouble.withUnsafeBytes {
//  buffBytes_s.append(contentsOf: $0)
//}
//
//print(buffBytes_s)
//
//var data: Data = Data(bytes: buffBytes_s)
//var data_t = data
//
//var buffBytes_t: [UInt8] = []
//buffBytes_t.append(contentsOf: data_t)
//print(buffBytes_t)
//
//var flag_t: UInt8 = buffBytes_s[0]
//switch flag_t {
//case flag.flag1.rawValue: print("flag1")
//default: print("flag2")
//}
//
//var bytesLen: [UInt8] = []
//for i in 1...8 {
//  bytesLen.append(buffBytes_t[i])
//}
//
//print(bytesLen)
//
//var value: Int = 0
//var v1 = Int(bytesLen[0])
//value = value | v1
//var v2 = Int(bytesLen[1])
//v2 = v2 << 8
//value = value | v2
//var v3 = Int(bytesLen[2])
//v3 = v3 << 16
//value = value | v3
//var v4 = Int(bytesLen[3])
//v4 = v4 << 24
//value = value | v4
//var v5 = Int(bytesLen[4])
//v5 = v5 << 32
//value = value | v5
//var v6 = Int(bytesLen[5])
//v6 = v6 << 40
//value = value | v6
//var v7 = Int(bytesLen[6])
//v7 = v7 << 48
//value = value | v7
//var v8 = Int(bytesLen[7])
//v8 = v8 << 56
//value = value | v8
//print(value)
//
//
//let intValue2 = bytesLen.withUnsafeBytes {
//  $0.baseAddress!.load(as: Int.self)
//}
//
//print(intValue2)
//
//var bytesDouble: [UInt8] = []
//for i in 16...23 {
//  bytesDouble.append(buffBytes_t[i])
//}
//print(bytesDouble)
//
//let doubleValue2 = bytesDouble.withUnsafeBytes {
//  $0.baseAddress!.load(as: Double.self)
//}
//
//print(doubleValue2)
//
//var intvalue_t: Int = 8
//var rst = withUnsafeBytes(of: &intvalue_t) {
//  Array($0)
//}
//print(rst)
//
//let strDate = "20171111111213"
//let df = DateFormatter()
//df.locale = Locale.current
//df.dateFormat = "yyyyMMddHHmmss"
//let date = df.date(from: strDate)
//print(date!)
//
//let datenow = Date()
//let str = df.string(from: datenow)
//print(str)
//
//let str2 = df.string(from: date!)
//print(str2)
//
//func toByteArray<T>(_ value: T) -> [UInt8] {
//  var value = value
//  return withUnsafeBytes(of: &value) { Array($0) }
//}
//
//func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
//  return value.withUnsafeBytes {
//    $0.baseAddress!.load(as: T.self)
//  }
//}
//
//let dt: UInt8 = 8
//let dt_Bytes = toByteArray(dt)
//print(dt_Bytes.count)

