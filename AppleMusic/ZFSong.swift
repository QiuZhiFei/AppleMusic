//
//  ZFSong.swift
//  DoubanRadio
//
//  Created by ZhiFei on 2017/9/7.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import SwiftyJSON
import Himotoki

struct ZFSong: Himotoki.Decodable {
  
  var identifier: String {
    return String(self.trackId)
  }
  
  let trackId: Int
  let title: String
  let artistName: String
  
  static func decode(_ e: Extractor) throws -> ZFSong {
    return try ZFSong(
      trackId: e <| "trackId",
      title: e <| "trackName",
      artistName: e <| "artistName"
    )
  }
  
}
