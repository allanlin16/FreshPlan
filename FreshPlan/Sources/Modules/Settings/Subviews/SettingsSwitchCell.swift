//
//  SettingsSliderCell.swift
//  FreshPlan
//
//  Created by Johnny Nguyen on 2017-12-30.
//  Copyright © 2017 St Clair College. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MaterialComponents

public final class SettingsSwitchCell: UITableViewCell {
  // MARK: Subjects
  public var title: PublishSubject<String> = PublishSubject()
  public var enabled: PublishSubject<Bool> = PublishSubject()
  
  // MARK: Views
  private var titleLabel: UILabel!
  private var switchView: UISwitch!
  
  // MARK: Conveinece operators
  public var isSwitchOn: Observable<Bool> {
    return switchView.rx.isOn
      .changed
      .asObservable()
  }
  
  private let disposeBag = DisposeBag()
  
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
    prepareSwitchView()
  }
  
  private func prepareTitleLabel() {
    titleLabel = UILabel()
    titleLabel.font = MDCTypography.subheadFont()
    
    contentView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { make in
      make.left.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    title
      .asObservable()
      .bind(to: titleLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  private func prepareSwitchView() {
    switchView = UISwitch()
    
    contentView.addSubview(switchView)
    
    switchView.snp.makeConstraints { make in
      make.right.equalTo(contentView).inset(10)
      make.centerY.equalTo(contentView)
    }
    
    enabled
      .asObservable()
      .bind(to: switchView.rx.isOn)
      .disposed(by: disposeBag)
  }
}
