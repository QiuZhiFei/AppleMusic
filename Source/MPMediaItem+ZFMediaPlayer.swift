//
//  MPMediaItem+ZFMediaPlayer.swift
//  Pods
//
//  Created by ZhiFei on 2017/12/11.
//

import Foundation
import MediaPlayer

public extension MPMediaItem {
  
  var appleID: String {
    if #available(iOS 10.3, *) {
      return self.playbackStoreID
    } else {
      return ""
    }
  }
  
}
