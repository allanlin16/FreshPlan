//
//  SendInviteFriendCell.swift
//  FreshPlan
//
//  Created by Allan Lin on 2018-01-07.
//  Copyright © 2018 St Clair College. All rights reserved.
//

import Foundation
import MaterialComponents
import RxSwift
import SnapKit

public final class SendInviteFriendCell: UITableViewCell {
  
  //MARK: Publish Subjects
  public var displayName: PublishSubject<String> = PublishSubject()
  public var email: PublishSubject<String> = PublishSubject()
  public var checked: PublishSubject<Bool> = PublishSubject()
  
  //MARK: ImageView
  private var displayNameLabel: UILabel!
  private var emailLabel: UILabel!
  private var inviterImageView: UIImageView!
  private var inkViewController: MDCInkTouchController!
  
  //MARK: disposeBag
  public let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    prepareView()
    
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func prepareView() {
    selectionStyle = .none
    separatorInset = .zero
    
    prepareDisplayNameLabel()
    prepareEmailLabel()
    prepareImageView()
    prepareInkView()
  }
  
  private func prepareDisplayNameLabel() {
    displayNameLabel = UILabel()
    displayNameLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(displayNameLabel)
    
    displayNameLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.top.equalTo(contentView)
    }
    
    displayName
      .asObservable()
      .bind(to: displayNameLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareEmailLabel() {
    emailLabel = UILabel()
    emailLabel.font = MDCTypography.body1Font()
    
    contentView.addSubview(emailLabel)
    
    emailLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.top.equalTo(displayNameLabel.snp.bottom)
    }
    
    email
      .asObservable()
      .bind(to: emailLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareImageView() {
    inviterImageView = UIImageView()
    inviterImageView.contentMode = .scaleAspectFit
    inviterImageView.image = UIImage(named: "ic_done")?.withRenderingMode(.alwaysTemplate)
    
    contentView.addSubview(inviterImageView)
    
    inviterImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(contentView)
      make.right.equalTo(contentView).offset(-15)
      make.width.equalTo(30)
      make.height.equalTo(30)
    }
    
    checked
      .asObservable()
      .map { $0 ? MDCPalette.green.tint400 : MDCPalette.grey.tint400 }
      .bind(to: inviterImageView.rx.tintColor)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
}

extension SendInviteFriendCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
