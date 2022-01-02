//
//  MeetupCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-16.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import RxSwift
import MaterialComponents
import SnapKit

public final class MeetupCell: UITableViewCell {
  //MARK: PublishSubject
  public var name: PublishSubject<String> = PublishSubject()
  public var startDate: PublishSubject<Date> = PublishSubject()
  public var endDate: PublishSubject<Date> = PublishSubject()
  
  //MARK: Views
  private var nameLabel: UILabel!
  private var dateLabel: UILabel!
  private var typeImageView: UIImageView!
  private var inkViewController: MDCInkTouchController!
  
  //MARK: DisposeBag
  private let disposeBag: DisposeBag = DisposeBag()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    accessoryType = .disclosureIndicator
    prepareImageView()
    prepareNameLabel()
    prepareDateLabel()
    prepareInkView()
  }
  
  private func prepareImageView() {
    typeImageView = UIImageView()
    typeImageView.contentMode = .scaleAspectFit
    typeImageView.image = UIImage(named: "ic_event")?.withRenderingMode(.alwaysTemplate)
    
    contentView.addSubview(typeImageView)
    
    typeImageView.snp.makeConstraints { make in
      make.width.equalTo(40)
      make.height.equalTo(40)
      make.centerY.equalTo(contentView)
      make.left.equalTo(contentView).inset(10)
    }
    
    endDate
      .asObservable()
      .filter { $0 < Date() }
      .map { _ in MDCPalette.red.tint400 }
      .bind(to: typeImageView.rx.tintColor)
      .disposed(by: disposeBag)
    
    endDate
      .asObservable()
      .filter { $0 > Date() }
      .map { _ in MDCPalette.green.tint400 }
      .bind(to: typeImageView.rx.tintColor)
      .disposed(by: disposeBag)
  }
  
  private func prepareNameLabel() {
    nameLabel = UILabel()
    nameLabel.numberOfLines = 0
    nameLabel.lineBreakMode = .byWordWrapping
    nameLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(nameLabel)
    
    nameLabel.snp.makeConstraints { make in
      make.left.equalTo(typeImageView.snp.right).offset(10)
      make.right.equalTo(contentView)
      make.top.equalTo(contentView).offset(20)
    }
    
    name
      .asObservable()
      .bind(to: nameLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareInkView() {
    inkViewController = MDCInkTouchController(view: self)
    inkViewController.delegate = self
    inkViewController.addInkView()
  }
  
  private func prepareDateLabel() {
    dateLabel = UILabel()
    dateLabel.numberOfLines = 0
    dateLabel.lineBreakMode = .byWordWrapping
    dateLabel.font = MDCTypography.captionFont()
    
    contentView.addSubview(dateLabel)
    
    dateLabel.snp.makeConstraints { make in
      make.left.equalTo(typeImageView.snp.right).offset(10)
      make.right.equalTo(contentView)
      make.top.equalTo(nameLabel.snp.bottom).offset(5)
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

extension MeetupCell: MDCInkTouchControllerDelegate {
  public func inkTouchController(_ inkTouchController: MDCInkTouchController, shouldProcessInkTouchesAtTouchLocation location: CGPoint) -> Bool {
    return true
  }
}
