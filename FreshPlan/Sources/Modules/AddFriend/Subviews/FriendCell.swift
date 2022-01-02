//
//  FriendCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-09.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents

public class FriendCell: UITableViewCell {
  // MARK:  Views
  private var inkViewController: MDCInkTouchController!
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
  }

  private func prepareView() {
    selectionStyle = .none
    prepareInkView()
    textLabel?.font = MDCTypography.subheadFont()
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK:  InkDelegate
extension FriendCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
