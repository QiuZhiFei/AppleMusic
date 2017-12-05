//
//  ZFMediaPlayerCountryHandler.swift
//  Pods
//
//  Created by ZhiFei on 2017/12/1.
//

import Foundation

open class ZFMediaPlayerCountryHandler {
  
  open fileprivate(set) var countrys: [String: String] = [:]
  
  open static let shared = ZFMediaPlayerCountryHandler()
  
  init() {
    setup()
  }
  
}

extension ZFMediaPlayerCountryHandler {
  
  func getCountryCode(_ countryCode: String?) -> String? {
    guard let countryCode = countryCode
      else { return nil }
    if let identifier = countryCode.components(separatedBy: ",").first, let countryCode = identifier.components(separatedBy: "-").first {
      return self.countrys[countryCode]
    }
    return nil
  }
  
}

fileprivate extension ZFMediaPlayerCountryHandler {
  
  func setup() {
    guard let plistURL = Bundle(for: ZFMediaPlayerCountryHandler.self).url(forResource: "CountryCodes", withExtension: "plist")
      else { return }
    guard let dic = NSDictionary(contentsOf: plistURL)
      else { return }
    guard dic is [String : String]
      else { return }
    self.countrys = dic as! [String : String]
  }
  
}
