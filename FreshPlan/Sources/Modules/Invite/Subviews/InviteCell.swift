//
//  InviteCell.swift
//  FreshPlan
//
//  Created by Allan Lin on 2017-12-17.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import UIKit
import MaterialComponents
import RxSwift
import SnapKit

public class InviteCell: UITableViewCell {
  
  // MARK: Views
  private var inkViewController: MDCInkTouchController!
  
  // MARK: PublishSubject
  public var inviter: PublishSubject<String> = PublishSubject()
  public var meetupName: PublishSubject<String> = PublishSubject()
  public var startDate: PublishSubject<Date> = PublishSubject()
  public var endDate: PublishSubject<Date> = PublishSubject()
  
  // Mark: ImageView
  private var inviteImageView: UIImageView!
  private var inviterImageView: UIImageView!
  
  // Mark: Label
  private var inviterLabel: UILabel!
  private var meetUpNameLabel: UILabel!
  private var dateLabel: UILabel!
  
  // MARK: DisposeBag
  private var disposeBag: DisposeBag = DisposeBag()
  
  // initializer require for tableview cell
  // set the indentifier
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    prepareView()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // prepare a reusable cell
  public override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // prepares the views
  private func prepareView() {
    // remove the selection style
    selectionStyle = .none
    prepareInviteImageView()
    prepareInviterLabel()
    prepareInviterImageView()
    prepareMeetupNameLabel()
    prepapreDateLabel()
    prepareInkView()
    
  }
  
  // prepare the inkViewController
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
  
  // imageview for cell checks the date
  private func prepareInviteImageView() {
    inviteImageView = UIImageView()
    inviteImageView.contentMode = .scaleAspectFit
    inviteImageView.image = UIImage(named: "ic_mail")?.withRenderingMode(.alwaysTemplate)
    
    contentView.addSubview(inviteImageView)
    
    inviteImageView.snp.makeConstraints { (make) in
      make.width.equalTo(40)
      make.height.equalTo(40)
      make.centerY.equalTo(contentView)
      make.left.equalTo(contentView).inset(10)
      
    }
    
    inviteImageView.tintColor = MDCPalette.red.tint400
    
  }
  
  //
  public func prepareMeetupNameLabel() {
    meetUpNameLabel = UILabel()
    meetUpNameLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(meetUpNameLabel)
    
    meetUpNameLabel.snp.makeConstraints { make in
      make.left.equalTo(inviteImageView.snp.right).offset(10)
      make.right.equalTo(inviterImageView.snp.left)
      make.top.equalTo(contentView).offset(20)
    }
    
    meetupName
      .asObserver()
      .bind(to: meetUpNameLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  public func prepareInviterImageView() {
    inviterImageView = UIImageView()
    inviterImageView.contentMode = .scaleAspectFit
    inviterImageView.image = UIImage(named: "ic_account_circle")?.withRenderingMode(.alwaysTemplate)
    
    contentView.addSubview(inviterImageView)
    
    inviterImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(inviterLabel)
      make.left.equalTo(inviterLabel.snp.left).offset(-25)
      
    }
  }
  
  // inviter name label for cell
  public func prepareInviterLabel() {
    inviterLabel = UILabel()
    inviterLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(inviterLabel)

    inviterLabel.snp.makeConstraints { make in
      make.right.equalTo(contentView.snp.right).offset(-20)
      make.top.equalTo(contentView).offset(20)
    }
    
    inviter
      .asObserver()
      .bind(to: inviterLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  // dateLabel for cell
  func prepapreDateLabel() {
    dateLabel = UILabel()
    dateLabel.font = MDCTypography.captionFont()
    
    contentView.addSubview(dateLabel)
    
    dateLabel.snp.makeConstraints { (make) in
      make.left.equalTo(inviteImageView.snp.right).offset(10)
      make.top.equalTo(inviterLabel.snp.bottom).offset(5)
    }
    
    Observable.combineLatest(startDate.asObservable(), endDate.asObservable()) { startDate, endDate -> String in
      let df = DateFormatter()
      df.dateFormat = "yyyy-MM-dd hh:mm:ss"
      let formattedString = "\(df.string(from: startDate)) | \(df.string(from: endDate))"
      return formattedString
      }
      .bind(to: dateLabel.rx.text)
      .disposed(by: disposeBag)
  }
}

// MARK:  InkDelegate
extension InviteCell: MDCInkTouchControllerDelegate {
  // determine if ink touch controller should be processing touches
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
