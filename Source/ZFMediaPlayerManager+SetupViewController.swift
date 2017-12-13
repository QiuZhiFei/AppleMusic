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
  open func getSubscribeVC(handler: ((SKCloudServiceSetupViewController)->())?) {
    let setupViewController = SKCloudServiceSetupViewController()
    setupViewController.delegate = self
    var setupOptions: [SKCloudServiceSetupOptionsKey: Any] = [
      .action: SKCloudServiceSetupAction.subscribe
    ]
    setupOptions[.iTunesItemIdentifier] = "playlists"
    if #available(iOS 11.0, *) {
      setupOptions[.messageIdentifier] = SKCloudServiceSetupMessageIdentifier.playMusic
    }
    setupViewController.load(options: setupOptions) { (a, b) in
      if let handler = handler {
        handler(setupViewController)
      }
    }
  }
  
  @available(iOS 10.1, *)
  public func cloudServiceSetupViewControllerDidDismiss(_ cloudServiceSetupViewController: SKCloudServiceSetupViewController) {
    print("dismiss")
  }
  
}
