//
//  ZFRefreshNormal.swift
//  ZFListViewDemo
//
//  Created by ZhiFei on 2017/11/29.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import ZFListView
import MJRefresh

class ZFListViewRefreshNormal: NSObject, ZFListViewRefresh {
  
  var tableView: UITableView {
    get {
      return self.intrinsicTableView
    }
  }
  
  fileprivate var intrinsicTableView: UITableView!
  
  required init(_ scrollView: UITableView) {
    super.init()
    self.intrinsicTableView = scrollView
  }
  
  func startTopRefreshing() {
    self.tableView.mj_header?.beginRefreshing()
  }
  
  func stopAllLoading() {
    self.tableView.mj_header?.endRefreshing()
    self.tableView.mj_footer?.endRefreshing()
  }
  
  func noticeNoMoreData() {
    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
  }
  
  func addTopPullToRefreshIfNeeded(handler: (() -> ())?) {
    if let _ = self.tableView.mj_header {
      return
    }
    
    let normalHeader = MJRefreshNormalHeader(refreshingBlock: {
      if let handler = handler {
        handler()
      }
    })
//    normalHeader?.setTitle("下拉刷新", for: .idle)
//    normalHeader?.setTitle("释放立即刷新", for: .pulling)
//    normalHeader?.setTitle("正在加载", for: .refreshing)
//    normalHeader?.setTitle("准备加载", for: .willRefresh)
//    normalHeader?.setTitle("没有更多", for: .noMoreData)
//
//    normalHeader?.lastUpdatedTimeLabel.isHidden = true
    
    self.tableView.mj_header = normalHeader
  }
  
  func removeTopPullToRefreshIfNeeded() {
    self.tableView.mj_header = nil
  }
  
  func addBottomPullToRefreshIfNeeded(handler: (() -> ())?) {
    if let _ = self.tableView.mj_footer {
      return
    }
    
    let footer = MJRefreshAutoNormalFooter(refreshingBlock: {
      if let handler = handler {
        handler()
      }
    })
//    footer?.setTitle("上拉刷新", for: .idle)
//    footer?.setTitle("释放立即刷新", for: .pulling)
//    footer?.setTitle("正在加载", for: .refreshing)
//    footer?.setTitle("准备加载", for: .willRefresh)
//    footer?.setTitle("没有更多", for: .noMoreData)
    self.tableView.mj_footer = footer
  }
  
  func removeBottomPullToRefreshIfNeeded() {
    self.tableView.mj_footer = nil
  }

}
