//
//  MDCTextFieldController+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-14.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MaterialComponents

extension Reactive where Base: MDCTextInputControllerDefault {
  public var errorText: Binder<String?> {
    return Binder(self.base) { (textInput: MDCTextInputControllerDefault, text: String?) -> Void in
      textInput.setErrorText(text, errorAccessibilityValue: nil)
    }
  }
}
