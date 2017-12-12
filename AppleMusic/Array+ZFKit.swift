//
//  Array+ZFKit.swift
//  
//
//  Created by zhifei on 16/6/1.
//  Copyright © 2016年 Douban Inc. All rights reserved.
//

import Foundation

func subArray<T>(_ array: [T], range: NSRange) -> [T] {
  if range.location > array.count || range.location < 0 || range.length < 0 {
    return []
  }
  return Array(array[range.location..<min(range.location + range.length, array.count)])
}

func +=<U,T>(lhs: inout [U:T], rhs: [U:T]) {
  for (key, value) in rhs {
    lhs[key] = value
  }
}
