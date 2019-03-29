//
//  ZFMediaPlayerManager+SetupViewController.swift
//  
//
//  Created by ZhiFei on 2017/11/17.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import MediaPlayer
import StoreKit

@available(iOS 10.1, *)
public typealias CloudServiceSetupViewControllerDidDismissHandler = (SKCloudServiceSetupViewController)->()

private var setupVCDidDismissHandlerKey = "setupVCDidDismissHandlerKey"

extension ZFMediaPlayerManager: SKCloudServiceSetupViewControllerDelegate {
  
  @available(iOS 10.1, *)
  open var setupVCDidDismissHandler: CloudServiceSetupViewControllerDidDismissHandler? {
    set {
      objc_setAssociatedObject(self, &setupVCDidDismissHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    get {
      if let value = objc_getAssociatedObject(self, &setupVCDidDismissHandlerKey){
        return value as? CloudServiceSetupViewControllerDidDismissHandler
      }
      return nil
    }
  }
  
  @available(iOS 10.1, *)
  open func getSubscribeVC(handler: ((SKCloudServiceSetupViewController?, Error?)->())?) {
    let setupViewController = SKCloudServiceSetupViewController()
    setupViewController.delegate = self
    var setupOptions: [SKCloudServiceSetupOptionsKey: Any] = [
      .action: SKCloudServiceSetupAction.subscribe
    ]
    setupOptions[.iTunesItemIdentifier] = "playlists"
    if #available(iOS 11.0, *) {
      setupOptions[.messageIdentifier] = SKCloudServiceSetupMessageIdentifier.playMusic
    }
    if #available(iOS 10.3, *) {
      if let token = musicAffiliateToken {
        setupOptions[SKCloudServiceSetupOptionsKey.affiliateToken] = token
      }
      if let token = musicCampaignToken {
        setupOptions[SKCloudServiceSetupOptionsKey.campaignToken] = token
      }
    }
    setupViewController.load(options: setupOptions) { (didSucceedLoading, error) in
      if let handler = handler {
        handler(didSucceedLoading ? setupViewController: nil, error)
      }
    }
  }
  
  @available(iOS 10.1, *)
  public func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
    debugPrint("cloudServiceSetupViewController dismiss")
    if let handler = self.setupVCDidDismissHandler {
      handler(cloudServiceSetupViewController)
    }
  }
  
}
