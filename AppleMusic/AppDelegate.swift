//
//  AppDelegate.swift
//  AppleMusic
//
//  Created by ZhiFei on 2017/12/1.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import UIKit
import ZFMediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    ZFMediaPlayerManager.configure(affiliateToken: nil)
    ZFMediaPlayerManager.configure(campaignToken: nil)
    
    let type = ZFMediaPlayerManager.authorizationType()
    debugPrint("authorizationType: \(type.rawValue)")
    switch type {
    case .notDetermined:
      debugPrint("没有请求授权，不可知")
    case .denied:
      debugPrint("用户不允许授权")
    case .authorized:
      debugPrint("用户允许授权")
    case .restricted:
      debugPrint("不应该提示授权")
    }
    
    let mediaPlayerManager = ZFMediaPlayerManager.shared
    mediaPlayerManager.cloudServiceCapabilitiesTypeDidChangeHandler = {
      [weak self] (type) in
      guard let `self` = self else { return }
      switch type {
      case .subscriptionEligible:
        debugPrint("Capabilities: 可以订阅，或许可以免费适用三月")
        if #available(iOS 10.1, *) {
          mediaPlayerManager.getSubscribeVC(handler: {
            [weak self] (setupVC, err) in
            guard let `self` = self else { return }
            if let setupVC = setupVC {
              self.window?.rootViewController?.present(setupVC, animated: true, completion: nil)
              return
            }
            ZFToast.show("apple music 注册页面加载失败", animated: true)
            debugPrint("getSubscribeVC err == \(String(describing: err))")
          })
        }
      case .playback:
        debugPrint("Capabilities: 可以播放")
      case .error:
        debugPrint("Capabilities: 获取失败")
      case .other:
        debugPrint("Capabilities: 获取成功，但没有可用的状态 -> 可能是低版本系统")
      case .unknown:
        debugPrint("Capabilities: 没获取")
      }
    }
    
    mediaPlayerManager.requestAuthorization {
      (authorized) in
      if authorized {
        ZFToast.show("授权成功")
        mediaPlayerManager.requestCapabilities()
      } else {
        ZFToast.show("授权失败")
      }
    }
    
    ZFMediaPlayerManager.shared.musicNowPlayingItemDidChangeHandler = {
      (item) in
      debugPrint("player: musicNowPlayingItemDidChange: \(String(describing: item?.zf_description)), index: \(ZFMediaPlayerManager.shared.indexOfNowPlayingItem)")
    }
    ZFMediaPlayerManager.shared.musicPlaybackStateDidChangeHandler = {
      (_, _) in
      debugPrint("player: musicPlaybackStateDidChangeHandler \(ZFMediaPlayerManager.shared.playbackState.rawValue)")
    }
    if #available(iOS 10.1, *) {
      ZFMediaPlayerManager.shared.setupVCDidDismissHandler = {
        (setupVC) in
        debugPrint("setupVC dismiss")
      }
    }
    
    NotificationCenter.default
      .addObserver(forName: NSNotification.musicPlayErrorNotification,
                   object: nil,
                   queue: OperationQueue.main) {
                    (noti) in
                    if let err = noti.object, let error = err as? NSError {
                      print("err = \(error)")
                    }
    }
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

