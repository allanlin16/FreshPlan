//
//  ProfileFriendCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-29.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents

public final class ProfileFriendCell: UITableViewCell {
  // MARK: Subjects
  public var title: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var inkController: MDCInkTouchController!
  
  private let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    accessoryType = .disclosureIndicator
    prepareInkView()
    prepareTitleLabel()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(contentView)
      make.left.equalTo(contentView).inset(10)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkController = MDCInkTouchController(view: self)
    inkController.delegate = self
    inkController.addInkView()
  }
}

extension ProfileFriendCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
