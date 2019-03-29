//
//  ViewController.swift
//  AppleMusic
//
//  Created by ZhiFei on 2017/12/1.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import UIKit
import ZFMediaPlayer
import ZFListView
import PureLayout

fileprivate let cellReuseIdentifier = "cellReuseIdentifier"

class ViewController: UIViewController {
  
  fileprivate let tableView = UITableView(frame: .zero, style: .plain)
  fileprivate let dataSource = ZFListViewNormalDataSource<ZFSong>()
  fileprivate let client = SonglistClient()
  
  fileprivate var listView: ZFListView<ZFSong>!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let refresh = ZFListViewRefreshNormal(tableView)
    listView = ZFListView(frame: .zero, refresh: refresh, client: client)
    listView.configure(moreRefreshEnabled: false)
    
    listView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    listView.tableView.delegate = dataSource
    listView.tableView.dataSource = dataSource
    
    dataSource.cellForRowHandler = {
      (tableView, indexPath, data) in
      let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
      cell.textLabel?.text = data?.title
      return cell
    }
    dataSource.didSelectRowHandler = {
      [weak self] (tableView, indexPath, data) in
      guard let `self` = self else { return }
      debugPrint("did select \(String(describing: data))")
      let storeIDs = self.getStoreIDs(indexPath: indexPath)
      ZFMediaPlayerManager.shared.playQueueWithStoreIDs(storeIDs)
//      ZFMediaPlayerManager.shared.playQueueWithStoreIDs(["311169153"])
    }
    
    view.addSubview(listView)
    _ = listView.autoPinEdgesToSuperviewEdges(with: .zero)
    
    ZFMediaPlayerManager.shared.requestStorefrontIdentifier {
      [weak self] (countryCode) in
      guard self != nil else { return }
      debugPrint("countryCode == \(String(describing: countryCode))")
      if let countryCode = countryCode {
        ZFToast.show("当前国家支持 \(countryCode)")
        
        refresh.startTopRefreshing()
      } else {
        ZFToast.show("当前国家不支持")
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

fileprivate extension ViewController {
  
  func getStoreIDs(indexPath: IndexPath) -> [String] {
    let songs = client.songs
    var songIDs: [String] = []
    songIDs = songs.map { (song) -> String in
      return "\(song.trackId)"
    }

    var result: [String] = []
    result += subArray(songIDs, range: NSRange(location: indexPath.row, length: songs.count - 1))
    result += subArray(songIDs, range: NSRange(location: 0, length: indexPath.row))
    
    return result
  }
  
}
