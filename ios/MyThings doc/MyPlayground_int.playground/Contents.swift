//: Playground - noun: a place where people can play

import UIKit

func toByteArray<T>(_ value: T) -> [UInt8] {
  var value = value
  return withUnsafeBytes(of: &value) { Array($0) }
}

func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
  return value.withUnsafeBytes {
    $0.baseAddress!.load(as: T.self)
  }
}


let n1 = 3

let bytesInt = toByteArray(n1)
print(bytesInt)

let n2 = fromByteArray(bytesInt, Int.self)
print(n2)




