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
  fileprivate let client = SonglistClient()
  
  fileprivate var listView: ZFListView<ZFSong>!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let refresh = ZFListViewRefreshNormal(tableView)
    listView = ZFListView(frame: .zero, refresh: refresh, client: client)
    listView.configure(moreRefreshEnabled: false)
    
    listView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    listView.cellForRowHandler = {
      (tableView, indexPath, data) in
      let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
      cell.textLabel?.text = data.title
      return cell
    }
    listView.didSelectRowHandler = {
      (tableView, indexPath, data) in
      debugPrint("did select \(data)")
      ZFMediaPlayerManager.shared().playQueueWithStoreIDs(<#T##storeIDs: [String]##[String]#>)
    }
    
    view.addSubview(listView)
    _ = listView.autoPinEdgesToSuperviewEdges(with: .zero)
    
    refresh.startTopRefreshing()
    
    ZFMediaPlayerManager.shared().requestStorefrontIdentifier {
      [weak self] (countryCode) in
      guard let `self` = self else { return }
      debugPrint("countryCode == \(String(describing: countryCode))")
      if let countryCode = countryCode {
        ZFToast.show("当前国家支持 \(countryCode)")
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

