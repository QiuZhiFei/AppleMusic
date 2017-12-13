//
//  ZFCloudServiceCapability.swift
//  Pods
//
//  Created by ZhiFei on 2017/12/14.
//

import Foundation
import MediaPlayer
import StoreKit

@objc public enum ZFCloudServiceCapabilityType : Int {
  case playback = 0 // 允许播放
  case subscriptionEligible // 允许订阅
  case other // 获取成功，但没有可用的状态 -> 可能是低版本系统
  case error // 错误
  case unknown // 没获取到
}

private var cloudServiceCapabilitiesKey = "cloudServiceCapabilitiesKey"

class ZFCloudServiceCapability: NSObject {
  
  var type: ZFCloudServiceCapabilityType = .unknown
  var typeChangeHandler: (()->())?
  
  @available(iOS 9.3, *)
  fileprivate var capability: SKCloudServiceCapability? {
    set {
      objc_setAssociatedObject(self, &cloudServiceCapabilitiesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    get {
      return objc_getAssociatedObject(self, &cloudServiceCapabilitiesKey) as? SKCloudServiceCapability
    }
  }
  
  fileprivate var err: Error?
  
}

extension ZFCloudServiceCapability {
  
  @available(iOS 9.3, *)
  func configure(capability: SKCloudServiceCapability, err: Error?) {
    self.capability = capability
    self.err = err
    self.updateType()
  }
  
}

fileprivate extension ZFCloudServiceCapability {
  
  func updateType() {
    let newType = getType()
    if self.type != newType {
      self.type = newType
      if let handler = typeChangeHandler {
        handler()
      }
    }
  }
  
  func getType() -> ZFCloudServiceCapabilityType {
    if let err = err {
      return .error
    }
    
    if #available(iOS 9.3, *) {
      guard let capability = self.capability else {
        return .unknown
      }
      if capability.contains(.musicCatalogPlayback) {
        return .playback
      }
      if #available(iOS 10.1, *) {
        if capability.contains(.musicCatalogSubscriptionEligible) && !capability.contains(.musicCatalogPlayback) {
          return .subscriptionEligible
        }
      }
    }
    
    return .other
  }
  
}
