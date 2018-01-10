//
//  AccountViewController.swift
//  AppleMusic
//
//  Created by ZhiFei on 2017/12/21.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import UIKit
import ZFMediaPlayer

class AccountViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func handleLogin(_ sender: Any) {
    if #available(iOS 10.1, *) {
      ZFMediaPlayerManager.shared.getSubscribeVC {
        [weak self] (setupVC, err) in
        guard let `self` = self else { return }
        if let setupVC = setupVC {
          self.present(setupVC, animated: true, completion: nil)
          return
        }
        ZFToast.show("apple music 注册页面加载失败", animated: true)
        debugPrint("getSubscribeVC err == \(String(describing: err))")
      }
    }
  }
  
}
