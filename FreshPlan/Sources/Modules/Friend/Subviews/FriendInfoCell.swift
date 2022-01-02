//
//  FriendInfoCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-09.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import SnapKit
import MaterialComponents

public class FriendInfoCell: UITableViewCell {
  //: MARK - PublishSubjects
  public var title: PublishSubject<String> = PublishSubject()
  public var type: PublishSubject<String> = PublishSubject()
  
  //: MARK - Views
  private var titleLabel: UILabel!
  private var typeLabel: UILabel!
  
  //: MARK - DisposeBag
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
    prepareTypeLabel()
    prepareTitleLabel()
  }
  
  private func prepareTypeLabel() {
    typeLabel = UILabel()
    typeLabel.font = MDCTypography.body2Font()
    
    contentView.addSubview(typeLabel)
    
    typeLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).offset(10)
      make.centerY.equalTo(contentView)
    }
    
    type
      .asObservable()
      .bind(to: typeLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.body1Font()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(typeLabel.snp.right).offset(5)
      make.centerY.equalTo(contentView)
    }
    
    title.asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
}
