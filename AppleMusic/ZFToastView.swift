//
//  ZFToastView.swift
//  DoubanRadio
//
//  Created by ZhiFei on 2017/9/7.
//  Copyright © 2017年 ZhiFei. All rights reserved.
//

import Foundation
import UIKit

class ZFToast: NSObject {
  
  fileprivate lazy var tostView: ZFToastView = {
    let view = ZFToastView(frame: .zero)
    return view
  }()
  fileprivate let duration: TimeInterval = 0.2
  fileprivate let height: CGFloat = 80
  fileprivate let hideDelay: TimeInterval = 3
  
  private static var manager: ZFToast!
  fileprivate static func shared() -> ZFToast {
    manager = manager ?? ZFToast()
    return manager
  }
  
}

extension ZFToast {
  
  static func show(_ text: String?, animated: Bool = true) {
    ZFToast.shared().show(text, animated: animated)
  }
  
  static func hide(_ animated: Bool = true) {
    ZFToast.shared().hide(animated)
  }
  
}

extension ZFToast {
  
  func show(_ text: String?, animated: Bool = true) {
    if Thread.isMainThread {
      intrinsicShow(text, animated: animated)
    } else {
      DispatchQueue.main.async {
        self.intrinsicShow(text, animated: animated)
      }
    }
  }
  
  func hide(_ animated: Bool = true) {
    if Thread.isMainThread {
      intrinsicHide(animated)
    } else {
      DispatchQueue.main.async {
        self.intrinsicHide(animated)
      }
    }
  }
  
}

fileprivate extension ZFToast {
  
  func intrinsicShow(_ text: String?, animated: Bool = true) {
    guard let text = text else { return }
    guard let appDelegate = UIApplication.shared.delegate else { return }
    guard let window = appDelegate.window else { return }
    
    if let window = window {
      cancelHide()
      
      window.addSubview(tostView)
      self.applyConstraints()
      tostView.configure(text: text)

      if animated {
        self.tostView.transform = CGAffineTransform(translationX: 0, y: -self.height)
        UIView.animate(withDuration: self.duration, animations: { 
          self.tostView.transform = CGAffineTransform.identity
        })
      }
      
      self.perform(#selector(self.hide(_:)), with: NSNumber(value: 1), afterDelay: self.hideDelay)
    }
  }
  
  func intrinsicHide(_ animated: Bool = true) {
    guard let _ = tostView.superview else { return }
    
    cancelHide()
    
    if animated {
      UIView.animate(withDuration: self.duration,
                     animations: { 
                      self.tostView.transform = CGAffineTransform(translationX: 0, y: -self.height)
      }, completion: { (finished) in
        self.tostView.transform = CGAffineTransform.identity
        self.tostView.removeFromSuperview()
      })
    } else {
      tostView.removeFromSuperview()
    }
  }
  
}

fileprivate extension ZFToast {
  
  func applyConstraints() {
    tostView.zf_layoutToSuperview(attribute: .top, constant: 0)
    tostView.zf_layoutToSuperview(attribute: .left, constant: 0)
    tostView.zf_layoutToSuperview(attribute: .right, constant: 0)
    let layout = NSLayoutConstraint(item: tostView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: self.height)
    tostView.superview?.addConstraint(layout)
  }
  
  func cancelHide() {
    NSObject.cancelPreviousPerformRequests(withTarget: self)
  }
  
}

fileprivate class ZFToastView: UIView {
  
  fileprivate lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 16)
    label.textColor = .white
    label.textAlignment = .center
    label.backgroundColor = .clear
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor(colorLiteralRed: 92/255.0, green: 188/255.0, blue: 125/255.0, alpha: 1)
    
    addSubview(label)
    label.zf_layoutToSuperview(attribute: .top, constant: 20)
    label.zf_layoutToSuperview(attribute: .left, constant: 0)
    label.zf_layoutToSuperview(attribute: .bottom, constant: 0)
    label.zf_layoutToSuperview(attribute: .right, constant: 0)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

extension ZFToastView {
  
  func configure(text: String?) {
    self.label.text = text
  }
  
}

extension UIView {
  
  func zf_layoutToSuperview(attribute: NSLayoutAttribute, constant: CGFloat) {
    guard let intrinsicSuperview = self.superview else { return }

    self.translatesAutoresizingMaskIntoConstraints = false
    let layout = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: intrinsicSuperview, attribute: attribute, multiplier: 1, constant: constant)
    intrinsicSuperview.addConstraint(layout)
  }
  
}
