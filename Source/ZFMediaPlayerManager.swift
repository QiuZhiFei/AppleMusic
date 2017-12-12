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
  case `repeat` // 单曲循环播放
  case shuffle // 按歌曲随机播放
  case shuffleAlbums // 按专辑随机播放
}

@objc public enum ZFMediaPlayerType: Int {
  case system = 0
  case application
}

@objc public enum ZFMusicAuthorizationType : Int {
  case notDetermined = 0
  case denied
  case restricted
  case authorized
  case unknown
}

var mediaPlayerType: ZFMediaPlayerType = .system

private var cloudServiceControllerKey = "cloudServiceControllerKey"

open class ZFMediaPlayerManager: NSObject {
  
  open var musicPlaybackStateDidChangeHandler: ((_ newState: MPMusicPlaybackState, _ oldState: MPMusicPlaybackState)->())?
  open var musicNowPlayingItemDidChangeHandler: ((MPMediaItem?)->())?
  open var musicVolumeDidChangeHandler: (()->())?
  
  open fileprivate(set) var countryCode: String?
  open fileprivate(set) var storeIDs: [String] = []
  open fileprivate(set) var authorizationType: ZFMusicAuthorizationType = .unknown
  
  var defaultPlayMode: ZFMusicPlayMode = .normal
  
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
  
  fileprivate var musicPlaybackState: MPMusicPlaybackState = .stopped
  fileprivate var intrinsicPlayMode: ZFMusicPlayMode?
  fileprivate var musicPlayer: MPMusicPlayerController!
  
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
  
  open var playMode: ZFMusicPlayMode {
    if let intrinsicPlayMode = self.intrinsicPlayMode {
      return intrinsicPlayMode
    }
    return self.defaultPlayMode
  }
  
  private static var manager: ZFMediaPlayerManager!
  open static func shared() -> ZFMediaPlayerManager {
    manager = manager ?? ZFMediaPlayerManager()
    return manager
  }
  
  override init() {
    super.init()
    
    switch mediaPlayerType {
    case .system:
      self.musicPlayer = MPMusicPlayerController.systemMusicPlayer()
    case .application:
      self.musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    }
    
    self.musicPlayer.beginGeneratingPlaybackNotifications()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.musicPlaybackStateDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.musicNowPlayingItemDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.musicVolumeDidChange(_:)), name: NSNotification.Name.MPMusicPlayerControllerVolumeDidChange, object: nil)
  }
  
}

extension ZFMediaPlayerManager {
  
  open func requestAuthorization(_ handler: ((_ authorized: Bool)->())?) {
    if #available(iOS 9.3, *) {
      SKCloudServiceController.requestAuthorization {
        [weak self] (status) in
        guard let `self` = self else { return }
        self.updateAuthorizationType(status: status)
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
  open func requestCapabilities() {
    if #available(iOS 9.3, *) {
      self.cloudServiceController.requestCapabilities {
        (capability, err) in
        //
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
    self.updatePlayModeIfNeeded()
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
    self.intrinsicPlayMode = playMode
    self.updatePlayModeIfNeeded()
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
    if let handler = self.musicPlaybackStateDidChangeHandler {
      handler(self.playbackState, self.musicPlaybackState)
    }
    self.musicPlaybackState = self.playbackState
  }
  @objc func musicNowPlayingItemDidChange(_ noti: Notification?) {
    if let handler = self.musicNowPlayingItemDidChangeHandler {
      handler(self.musicPlayer.nowPlayingItem)
    }
  }
  @objc func musicVolumeDidChange(_ noti: Notification?) {
    if let handler = self.musicVolumeDidChangeHandler {
      handler()
    }
  }
  
}

fileprivate extension ZFMediaPlayerManager {
  
  func updatePlayModeIfNeeded() {
    switch self.playMode {
    case .normal:
      self.musicPlayer.shuffleMode = .off
      self.musicPlayer.repeatMode = .all
    case .repeat:
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
  func updateAuthorizationType(status: SKCloudServiceAuthorizationStatus) {
    var type: ZFMusicAuthorizationType = .unknown
    switch status {
    case .notDetermined:
      type = .notDetermined
    case .denied:
      type = .denied
    case .restricted:
      type = .restricted
    case .authorized:
      type = .authorized
    }
    self.authorizationType = type
  }
  
}
