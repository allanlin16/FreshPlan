//
//  UITextField+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-23.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
  public var placeholder: Binder<String?> {
    return Binder(self.base) { textField, placeholder in
      textField.placeholder = placeholder
    }
  }
}
