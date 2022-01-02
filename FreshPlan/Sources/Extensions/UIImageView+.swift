//
//  UIImageView+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: UIImageView {
  public var tintColor: Binder<UIColor> {
    return Binder(self.base) { imageView, tintColor in
      imageView.tintColor = tintColor
    }
  }
}
