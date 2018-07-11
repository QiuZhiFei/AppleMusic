//
//  MPMediaLibraryQueue.swift
//  Pods
//
//  Created by ZhiFei on 2018/5/14.
//

import Foundation
import MediaPlayer

class MPMediaLibraryQueue: NSObject {
  
  fileprivate let queue = DispatchQueue(label: "com.apple.music.zf.media.sync")
  fileprivate var configs: [MPMediaPlaylist: MPMediaLibraryQueueConfig] = [:]
  
  @available(iOS 9.3, *)
  open func addItems(_ items: [String], mediaPlaylist: MPMediaPlaylist) {
    let config = self.getConfig(mediaPlaylist: mediaPlaylist)
    if config.items.count != 0 {
      config.add(items: items)
      return
    }
    
    config.add(items: items)
    self.queue.async {
      self.startSyncTask(config: config)
    }
  }
  
  @available(iOS 9.3, *)
  open func addItem(_ item: String, mediaPlaylist: MPMediaPlaylist) {
    self.addItems([item], mediaPlaylist: mediaPlaylist)
  }
  
}

fileprivate extension MPMediaLibraryQueue {
  
  func startSyncTask(config: MPMediaLibraryQueueConfig) {
    guard let item = config.items.first else {
      return
    }
    
    if #available(iOS 9.3, *) {
      config.mediaPlaylist.addItem(withProductID: item) {
        [weak self] (err) in
        guard let `self` = self else { return }
        if let err = err as? MPError {
          if err.code == MPError.Code.permissionDenied || err.code == MPError.Code.cloudServiceCapabilityMissing {
            // 不支持 sync，停止 sync
            self.endSyncTask(config: config)
            return
          }
        }
        
        self.syncTaskCompleted(config: config, item: item, err: err)
      }
    } else {
      // Fallback on earlier versions
    }
  }
  
  func syncTaskCompleted(config: MPMediaLibraryQueueConfig,  item: String, err: Error?) {
    config.remove(item: item)
    
    self.queue.async {
      self.startSyncTask(config: config)
    }
  }
  
  func endSyncTask(config: MPMediaLibraryQueueConfig) {
    config.items = []
  }
  
  func getConfig(mediaPlaylist: MPMediaPlaylist) -> MPMediaLibraryQueueConfig {
    if let value = self.configs[mediaPlaylist] {
      return value
    }
    let config = MPMediaLibraryQueueConfig(mediaPlaylist: mediaPlaylist)
    self.configs[mediaPlaylist] = config
    return config
  }
  
}

fileprivate class MPMediaLibraryQueueConfig: NSObject {
  
  internal fileprivate(set) var items: [String] = []
  internal fileprivate(set) var mediaPlaylist: MPMediaPlaylist!
  
  init(mediaPlaylist: MPMediaPlaylist) {
    super.init()
    self.mediaPlaylist = mediaPlaylist
  }
  
  func configure(items: [String]) {
    self.items = items
  }
  
  func add(items: [String]) {
    var result = self.items
    let addItems = items.filter{ !self.items.contains($0) }
    result.append(contentsOf: addItems)
    self.configure(items: result)
  }
  
  func add(item: String) {
    self.items.append(item)
  }
  
  func remove(item: String) {
    if let index = self.items.index(of: item) {
      self.items.remove(at: index)
    }
  }
  
}
