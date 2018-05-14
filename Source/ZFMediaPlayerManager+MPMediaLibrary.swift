//
//  ZFMediaPlayerManager+MPMediaLibrary.swift
//  
//
//  Created by ZhiFei on 2017/11/17.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import MediaPlayer

fileprivate var mediaLibraryQueueKey = "mediaLibraryQueueKey"

extension ZFMediaPlayerManager {
  
  fileprivate var queue: MPMediaLibraryQueue {
    set {
      //
    }
    get {
      if let value = objc_getAssociatedObject(self, &mediaLibraryQueueKey) as? MPMediaLibraryQueue {
        return value
      }
      let queue = MPMediaLibraryQueue()
      objc_setAssociatedObject(self, &mediaLibraryQueueKey, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return queue
    }
  }
  
  @available(iOS 9.3, *)
  open func createPlaylistIfNeeded(with uuid: UUID,
                                   creationMetadata: MPMediaPlaylistCreationMetadata?,
                                   completionHandler: ((MPMediaPlaylist?, Error?) -> ())?) {
    MPMediaLibrary.default()
      .getPlaylist(with: uuid,
                   creationMetadata: creationMetadata) {
                    [weak self] (list, err) in
                    guard let `self` = self else { return }
                    if let handler = completionHandler {
                      handler(list, err)
                    }
    }
  }
  
  @available(iOS 9.3, *)
  open func getPlaylist(with uuid: UUID,
                        creationMetadata: MPMediaPlaylistCreationMetadata?,
                        completionHandler: ((MPMediaPlaylist?, Error?) -> ())?) {
    MPMediaLibrary.default()
      .getPlaylist(with: uuid,
                   creationMetadata: creationMetadata) {
                    [weak self] (list, err) in
                    guard let `self` = self else { return }
                    if let handler = completionHandler {
                      handler(list, err)
                    }
    }
  }
  
  @available(iOS 9.3, *)
  open func addItem(identifier: String, mediaPlaylist: MPMediaPlaylist, handler: ((Error?)->())?) {
    self.queue.addItem(identifier, mediaPlaylist: mediaPlaylist)
  }
  
  @available(iOS 9.3, *)
  open func addItems(_ items: [String], mediaPlaylist: MPMediaPlaylist, handler: (()->())?) {
    self.queue.addItems(items, mediaPlaylist: mediaPlaylist)
  }
  
  @available(iOS 9.3, *)
  open func addPlaylistItems(with uuid: UUID,
                             creationMetadata: MPMediaPlaylistCreationMetadata?,
                             items: [String],
                             completionHandler: ((MPMediaPlaylist?, Error?) -> ())?) {
    self.getPlaylist(with: uuid,
                     creationMetadata: creationMetadata) {
                      [weak self] (playlist, error) in
                      guard let `self` = self else { return }
                      if let error = error {
                        debugPrint("get playlist error: \(error)")
                        return
                      }
                      guard let playlist = playlist else {
                        debugPrint("get playlist error: playlist is nil")
                        return
                      }
                      debugPrint("items == \(playlist.items)")
                      for item in items {
                        self.addItem(identifier: item,
                                     mediaPlaylist: playlist,
                                     handler: { (err) in
                                      debugPrint("add item error: \(err)")
                        })
                      }
    }
  }
  
}
