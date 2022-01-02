//
//  UISearchBar+.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UISearchBar {
  public var placeholder: Binder<String?> {
    return Binder(self.base) { searchBar, placeholder in
      searchBar.placeholder = placeholder
    }
  }
}
