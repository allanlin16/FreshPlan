//
//  MeetupDirectionCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-21.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import MaterialComponents

public final class MeetupDirectionCell: UITableViewCell {
  // MARK: PublishSubject
  public var title: PublishSubject<String> = PublishSubject()
  
  // MARK: View
  private var buttonLabel: UILabel!
  private var inkViewController: MDCInkTouchController!
  
  // MARK: Dispsose
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
    backgroundColor = MDCPalette.green.tint400
    prepareButtonLabel()
    prepareInkView()
  }
  
  private func prepareButtonLabel() {
    buttonLabel = UILabel()
    buttonLabel.font = MDCTypography.body2Font()
    buttonLabel.textColor = .white
    
    contentView.addSubview(buttonLabel)
    
    buttonLabel.snp.makeConstraints { make in
      make.center.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: buttonLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

// MARK: InkView
extension MeetupDirectionCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
