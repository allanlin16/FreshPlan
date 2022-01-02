//
//  AddMeetupGeocodeCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-22.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import MaterialComponents

public final class EditMeetupGeocodeCell: UITableViewCell {
  //MARK: Subjects
  public var title: PublishSubject<String> = PublishSubject()
  
  //MARK: Views
  private var titleLabel: UILabel!
  private var textField: UITextField!
  private var inkViewController: MDCInkTouchController!
  
  //MARK: Events
  public var textFieldText: ControlProperty<String?> {
    return textField.rx.text
  }
  
  //MARK: Dispose
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
    prepareTitleLabel()
    prepareTextField()
    prepareInkView()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.boldFont(from: MDCTypography.subheadFont())
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareTextField() {
    textField = UITextField()
    textField.placeholder = "Click me to enter in your location"
    textField.isEnabled = false
    textField.textAlignment = .center
    textField.font = MDCTypography.body1Font()
    
    contentView.addSubview(textField)
    
    textField.snp.makeConstraints { make in
      make.left.equalTo(titleLabel.snp.right).offset(10)
      make.right.equalTo(contentView).offset(-10)
      make.centerY.equalTo(contentView)
    }
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

extension EditMeetupGeocodeCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}

