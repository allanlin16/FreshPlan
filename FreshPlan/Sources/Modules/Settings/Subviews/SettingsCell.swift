//
//  SettingsCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-30.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import MaterialComponents

public final class SettingsCell: UITableViewCell {
  // MARK: Subjects
  public var title: PublishSubject<String> = PublishSubject()
  public var subtitle: PublishSubject<String> = PublishSubject()
  
  // MARK: Views
  private var inkViewController: MDCInkTouchController!
  
  private let disposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    prepareTitleLabel()
    prepareSubtitleLabel()
    prepareInkView()
  }
  
  private func prepareTitleLabel() {
    textLabel?.font = MDCTypography.subheadFont()
    
    title
      .asObservable()
      .bind(to: textLabel!.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareSubtitleLabel() {
    detailTextLabel?.font = MDCTypography.body1Font()
    
    subtitle
      .asObservable()
      .bind(to: detailTextLabel!.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

extension SettingsCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
