//
//  ZFMediaPlayerManager+MPMediaLibrary.swift
//  
//
//  Created by ZhiFei on 2017/11/17.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import MediaPlayer

extension ZFMediaPlayerManager {
  
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
    mediaPlaylist.addItem(withProductID: identifier) { (err) in
      if let handler = handler {
        handler(err)
      }
    }
  }
  
}
