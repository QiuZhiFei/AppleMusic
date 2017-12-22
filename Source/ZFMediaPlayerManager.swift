//
//  ZFMediaPlayerManager.swift
//  
//
//  Created by ZhiFei on 2017/9/7.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import MediaPlayer
import StoreKit

@objc public enum ZFMusicPlayMode : Int {
  case normal = 0 // 顺序播放
  case single // 单曲循环播放
  case shuffle // 按歌曲随机播放
  case shuffleAlbums // 按专辑随机播放
}

@objc public enum ZFMediaPlayerType: Int {
  case system = 0
  case application
}

@objc public enum ZFMusicAuthorizationType : Int {
  case notDetermined = 0 // 没有请求授权
  case denied // 用户不允许授权
  case restricted // 不应该提示授权
  case authorized // 用户允许授权
}

public extension NSNotification {
  static let musicPlaybackStateDidChange = Notification.Name("com.zf.musicPlaybackStateDidChange")
  static let musicNowPlayingItemDidChange = Notification.Name("com.zf.musicNowPlayingItemDidChange")
  static let musicVolumeDidChange = Notification.Name("com.zf.musicVolumeDidChange")
  static let cloudServiceCapabilitiesTypeDidChange = Notification.Name("com.zf.cloudServiceCapabilitiesTypeDidChange")
}

var mediaPlayerType: ZFMediaPlayerType = .system
var defaultPlayMode: ZFMusicPlayMode = .normal

public var musicAffiliateToken: String?
public var musicCampaignToken: String?

private var cloudServiceControllerKey = "cloudServiceControllerKey"

open class ZFMediaPlayerManager: NSObject {
  
  open static let shared = ZFMediaPlayerManager()
  
  open var musicPlaybackStateDidChangeHandler: ((_ newState: MPMusicPlaybackState, _ oldState: MPMusicPlaybackState)->())?
  open var musicNowPlayingItemDidChangeHandler: ((MPMediaItem?)->())?
  open var musicVolumeDidChangeHandler: (()->())?
  open var cloudServiceCapabilitiesTypeDidChangeHandler: ((ZFCloudServiceCapabilityType)->())?
  
  open fileprivate(set) var countryCode: String?
  open fileprivate(set) var storeIDs: [String] = []
  
  open var nowPlayerType: ZFMediaPlayerType {
    if self.musicPlayer == MPMusicPlayerController.systemMusicPlayer() {
      return .system
    }
    return .application
  }
  open var indexOfNowPlayingItem: Int {
    return self.musicPlayer.indexOfNowPlayingItem
  }
  open var nowPlayingItem: MPMediaItem? {
    return self.musicPlayer.nowPlayingItem
  }
  open var currentPlaybackTime: TimeInterval {
    return self.musicPlayer.currentPlaybackTime
  }
  open var playbackState: MPMusicPlaybackState {
    return self.musicPlayer.playbackState
  }
  open var cloudServiceCapabilitiesType: ZFCloudServiceCapabilityType {
    return self.cloudServiceCapabilities.type
  }
  open var playMode: ZFMusicPlayMode {
    return self.getPlayMode()
  }
  
  fileprivate var musicPlaybackState: MPMusicPlaybackState = .stopped
  fileprivate var configuredPlayMode: ZFMusicPlayMode?
  fileprivate var musicPlayer: MPMusicPlayerController!
  fileprivate var cloudServiceCapabilities = ZFCloudServiceCapability()
  @available(iOS 9.3, *)
  fileprivate var cloudServiceController: SKCloudServiceController {
    set {
      //
    }
    get {
      if let value = objc_getAssociatedObject(self, &cloudServiceControllerKey), value is SKCloudServiceController {
        return value as! SKCloudServiceController
      }
      let cloudServiceController = SKCloudServiceController()
      objc_setAssociatedObject(self, &cloudServiceControllerKey, cloudServiceController, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return cloudServiceController
    }
  }
  
  override init() {
    super.init()
    
    switch mediaPlayerType {
    case .system:
      self.musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    case .application:
      self.musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    }
    
    self.cloudServiceCapabilities.typeChangeHandler = {
      [weak self] in
      guard let `self` = self else { return }
      if let handler = self.cloudServiceCapabilitiesTypeDidChangeHandler {
        handler(self.cloudServiceCapabilities.type)
      }
      NotificationCenter.default.post(name: NSNotification.cloudServiceCapabilitiesTypeDidChange, object: nil)
    }
    
    self.musicPlayer.beginGeneratingPlaybackNotifications()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlaybackStateDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.musicNowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.musicVolumeDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: nil)
  }
  
}

extension ZFMediaPlayerManager {
  
  open static func authorizationType() -> ZFMusicAuthorizationType  {
    if #available(iOS 9.3, *) {
      let type = ZFMediaPlayerManager.getAuthorizationType(status: SKCloudServiceController.authorizationStatus())
      return type
    } else {
      return .notDetermined
    }
  }
  
  // 请求授权
  open func requestAuthorization(_ handler: ((_ authorized: Bool)->())?) {
    debugPrint("请求授权")
    
    let type = ZFMediaPlayerManager.authorizationType()
    
    if type == .authorized {
      self.requestCapabilities()
    }
    if type != .notDetermined {
      if let handler = handler {
        handler(type == .authorized)
      }
      return
    }
    
    if #available(iOS 9.3, *) {
      SKCloudServiceController.requestAuthorization {
        [weak self] (status) in
        guard let `self` = self else { return }
        debugPrint("requestAuthorization status: \(status.rawValue), cur status: \(ZFMediaPlayerManager.authorizationType().rawValue)")
        self.requestCapabilities()
        if let handler = handler {
          DispatchQueue.main.async {
            handler(status == .authorized)
          }
        }
      }
    } else {
      debugPrint("\(#file): \(#line) \(#function) requires iOS 9.3 or later")
    }
  }
  
  // 获取当前功能
  open func requestCapabilities() {
    debugPrint("请求功能")
    if ZFMediaPlayerManager.authorizationType() != .authorized {
      return
    }
    if #available(iOS 9.3, *) {
      self.cloudServiceController.requestCapabilities {
        [weak self] (cloudServiceCapabilities, err) in
        guard let `self` = self else { return }
        debugPrint("requestCapabilities: \(cloudServiceCapabilities), err: \(err)")
        DispatchQueue.main.async {
          self.cloudServiceCapabilities.configure(capability: cloudServiceCapabilities, err: err)
        }
      }
    } else {
      debugPrint("\(#file): \(#line) \(#function) requires iOS 9.3 or later")
    }
  }
  
  open func requestStorefrontIdentifier(_ handler: ((String?)->())?) {
    if #available(iOS 9.3, *) {
      self.cloudServiceController.requestStorefrontIdentifier {
        (countryCode, err) in
        if let handler = handler {
          DispatchQueue.main.async {
            self.configure(countryCode: ZFMediaPlayerCountryHandler.shared.getCountryCode(countryCode))
            handler(self.countryCode)
          }
        }
      }
    } else {
      debugPrint("\(#file): \(#line) \(#function) requires iOS 9.3 or later")
    }
  }
  
}

extension ZFMediaPlayerManager {
  
  open static func configure(affiliateToken: String?) {
    musicAffiliateToken = affiliateToken
  }
  
  open static func configure(campaignToken: String?) {
    musicCampaignToken = campaignToken
  }
  
  open func configure(countryCode: String?) {
    self.countryCode = countryCode
  }
  
  open static func configure(type: ZFMediaPlayerType) {
    mediaPlayerType = type
  }
  
  open func setQueueWithStoreIDs(_ storeIDs: [String]) {
    self.storeIDs = storeIDs
    if #available(iOS 9.3, *) {
      self.musicPlayer.setQueueWithStoreIDs(storeIDs)
    } else {
      debugPrint("\(#file): \(#line) \(#function) requires iOS 9.3 or later")
    }
    //    self.musicPlayer.prepareToPlay()
  }
  open func play() {
    self.updatePlayMode(self.playMode)
    self.musicPlayer.play()
  }
  
  open func playQueueWithStoreIDs(_ storeIDs: [String]) {
    self.setQueueWithStoreIDs(storeIDs)
    self.play()
  }
  
  open func pause() {
    self.musicPlayer.pause()
  }
  
  open func stop() {
    self.musicPlayer.stop()
  }
  
  open func toggle() {
    if self.playbackState == .playing {
      self.pause()
    } else {
      self.play()
    }
  }
  
  open func skipToNextItem() {
    self.musicPlayer.skipToNextItem()
  }
  
  open func skipToPreviousItem() {
    self.musicPlayer.skipToPreviousItem()
  }
  
  open func configure(playMode: ZFMusicPlayMode) {
    self.configuredPlayMode = playMode
    self.updatePlayMode(playMode)
  }
  
  open func removeItem() {
    if #available(iOS 10.3, *) {
      let player = MPMusicPlayerController.applicationQueuePlayer()
      player.performQueueTransaction({ (queue) in
        queue.removeItem(queue.items.last!)
      }) { (queue, error) in
        //
      }
    } else {
      // Fallback on earlier versions
    }
  }
  
}

fileprivate extension ZFMediaPlayerManager {
  
  @objc func musicPlaybackStateDidChange(_ noti: Notification?) {
    if self.cloudServiceCapabilitiesType != .playback {
      return
    }
    if let handler = self.musicPlaybackStateDidChangeHandler {
      handler(self.playbackState, self.musicPlaybackState)
    }
    self.musicPlaybackState = self.playbackState
    NotificationCenter.default.post(name: NSNotification.musicPlaybackStateDidChange, object: nil)
  }
  
  @objc func musicNowPlayingItemDidChange(_ noti: Notification?) {
    if self.cloudServiceCapabilitiesType != .playback {
      return
    }
    if let handler = self.musicNowPlayingItemDidChangeHandler {
      handler(self.musicPlayer.nowPlayingItem)
    }
    NotificationCenter.default.post(name: NSNotification.musicNowPlayingItemDidChange, object: nil)
  }
  
  @objc func musicVolumeDidChange(_ noti: Notification?) {
    if let handler = self.musicVolumeDidChangeHandler {
      handler()
    }
    NotificationCenter.default.post(name: NSNotification.musicVolumeDidChange, object: nil)
  }
  
}

fileprivate extension ZFMediaPlayerManager {
  
  func getPlayMode() -> ZFMusicPlayMode {
    guard let configuredPlayMode = configuredPlayMode else {
      return defaultPlayMode
    }
    if self.musicPlayer.repeatMode == .one {
      return .single
    }
    if self.musicPlayer.shuffleMode == .songs
      && self.musicPlayer.repeatMode == .none {
      return .shuffle
    }
    if self.musicPlayer.shuffleMode == .albums
      && self.musicPlayer.repeatMode == .none {
      return .shuffleAlbums
    }
    return .normal
  }
  
  func updatePlayMode(_ playMode: ZFMusicPlayMode) {
    switch playMode {
    case .normal:
      self.musicPlayer.shuffleMode = .off
      self.musicPlayer.repeatMode = .all
    case .single:
      self.musicPlayer.shuffleMode = .off
      self.musicPlayer.repeatMode = .one
    case .shuffle:
      self.musicPlayer.shuffleMode = .songs
      self.musicPlayer.repeatMode = .none
    case .shuffleAlbums:
      self.musicPlayer.shuffleMode = .albums
      self.musicPlayer.repeatMode = .none
    }
  }
  
  @available(iOS 9.3, *)
  static func getAuthorizationType(status: SKCloudServiceAuthorizationStatus) -> ZFMusicAuthorizationType {
    switch status {
    case .notDetermined:
      return .notDetermined
    case .denied:
      return .denied
    case .restricted:
      return .restricted
    case .authorized:
      return .authorized
    }
  }
  
}
