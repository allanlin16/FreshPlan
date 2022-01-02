//
//  UIDatePicker+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-23.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIDatePicker {
  public var minDate: Binder<Date?> {
    return Binder(self.base) { datePicker, minDate in
      datePicker.minimumDate = minDate
    }
  }
}
