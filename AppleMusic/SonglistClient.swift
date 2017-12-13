//
//  SonglistClient.swift
//  AppleMusic
//
//  Created by ZhiFei on 2017/12/1.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import ZFListView
import ZFMediaPlayer
import Alamofire
import SwiftyJSON

class SonglistClient: ZFListClient<ZFSong> {
  
  internal fileprivate(set) var songs: [ZFSong] = []
  
  override func loadTop(page: Int, handler: (([ZFSong], Error?) -> ())?) {
    super.loadTop(page: page, handler: handler)
    
    let keyword = "王菲"
    var parameters = [
      "isStreamable" : true,
      "term" : keyword,
      "media" : "music",
      "limit" : 9
      ] as [String : Any];
    
    guard let countryCode = ZFMediaPlayerManager.shared.countryCode else {
      assertionFailure("countryCode should not be nil")
      return
    }
    parameters["country"] = countryCode
    
    Alamofire.request("https://itunes.apple.com/search",
                      method: .get,
                      parameters: parameters)
      .responseJSON(completionHandler: { (response) in
        var songs: [ZFSong] = []
        if let data = response.data, let obj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
          let results = JSON(obj)["results"].arrayValue
          for json in results {
            if let song = try? ZFSong.decodeValue(json.dictionaryObject! as [String: AnyObject]) {
              songs.append(song)
            }
          }
        }
        self.songs = songs
        if let handler = handler {
          handler(songs, response.error)
        }
      })
  }
  
  override func loadMore(page: Int, handler: (([ZFSong], Error?) -> ())?) {
    super.loadMore(page: page, handler: handler)
  }
  
}
