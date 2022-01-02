//
//  SearchBar.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-03.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MaterialComponents

/**
 * Our custom made search bar
 * We'll customize it here, so that it's much better and more orientated for us.
**/
public final class SearchBar: UISearchBar {  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    prepareView()
  }
  
  private func prepareView() {
    prepareSearchBar()
    prepareTextField()
  }
  
  private func prepareSearchBar() {
    searchBarStyle = .minimal
    showsBookmarkButton = false
    tintColor = .white
  }
  
  /**
   * There's no standard way of editing the textfield inside the searchbar, but one workaround
   * is to use the key-value compliant method.
  **/
  private func prepareTextField() {
    let textField = self.value(forKey: "searchField") as? UITextField
    textField?.font = MDCTypography.body2Font()
    textField?.textColor = .white

  }
}
