//
//  MPMediaLibraryQueue.swift
//  Pods
//
//  Created by ZhiFei on 2018/5/14.
//

import Foundation
import MediaPlayer

class MPMediaLibraryQueue: NSObject {
  
  fileprivate var isLoading = false
  fileprivate var configs: [MPMediaPlaylist: MPMediaLibraryQueueConfig] = [:]
  
  @available(iOS 9.3, *)
  open func addItems(_ items: [String], mediaPlaylist: MPMediaPlaylist) {
    let config = self.getConfig(mediaPlaylist: mediaPlaylist)
    config.add(items: items)
    self.addConfig(config)
  }
  
  @available(iOS 9.3, *)
  open func addItem(_ item: String, mediaPlaylist: MPMediaPlaylist) {
    let config = self.getConfig(mediaPlaylist: mediaPlaylist)
    config.add(item: item)
    self.addConfig(config)
  }
  
}

fileprivate extension MPMediaLibraryQueue {
  
  func addConfig(_ config: MPMediaLibraryQueueConfig) {
    if self.isLoading {
      return
    }
    addIntrinsicConfig(config)
  }
  
  func addIntrinsicConfig(_ config: MPMediaLibraryQueueConfig) {
    if config.items.count == 0 {
      self.isLoading = false
      return
    }
    self.isLoading = true
    let item = config.items.first!
    if #available(iOS 9.3, *) {
      config.mediaPlaylist.addItem(withProductID: item) {
        [weak self] (err) in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          config.remove(item: item)
          self.addIntrinsicConfig(config)
        }
      }
    } else {
      // Fallback on earlier versions
    }
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
